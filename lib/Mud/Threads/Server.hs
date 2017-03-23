{-# OPTIONS_GHC -Wno-redundant-constraints #-}
{-# LANGUAGE LambdaCase, OverloadedStrings, ViewPatterns #-}

module Mud.Threads.Server (threadServer) where

import           Mud.Cmds.Msgs.Misc
import           Mud.Data.Misc
import           Mud.Data.State.ActionParams.ActionParams
import           Mud.Data.State.MsgQueue
import           Mud.Data.State.MudData
import           Mud.Data.State.Util.Egress
import           Mud.Data.State.Util.Get
import           Mud.Data.State.Util.Misc
import           Mud.Data.State.Util.Output
import           Mud.Interp.CentralDispatch
import           Mud.Misc.ANSI
import qualified Mud.Misc.Logging as L (logNotice)
import           Mud.Misc.Persist
import           Mud.Threads.Act
import           Mud.Threads.Biodegrader
import           Mud.Threads.CorpseDecomposer
import           Mud.Threads.Digester
import           Mud.Threads.Effect
import           Mud.Threads.InacTimer
import           Mud.Threads.Misc
import           Mud.Threads.NpcServer
import           Mud.Threads.Regen
import           Mud.Threads.RmFuns
import           Mud.Threads.SpiritTimer
import           Mud.TopLvlDefs.FilePaths
import           Mud.TopLvlDefs.Seconds
import           Mud.Util.List
import           Mud.Util.Misc
import           Mud.Util.Operators
import           Mud.Util.Quoting
import           Mud.Util.Text hiding (headTail)

import           Control.Concurrent (killThread)
import           Control.Concurrent.Async (wait)
import           Control.Concurrent.STM (atomically)
import           Control.Concurrent.STM.TMQueue (writeTMQueue)
import           Control.Concurrent.STM.TQueue (readTQueue, writeTQueue)
import           Control.Exception.Lifted (catch, handle)
import           Control.Lens (view, views)
import           Control.Lens.Operators ((^.))
import           Control.Monad ((>=>), forM_, unless)
import           Control.Monad.IO.Class (liftIO)
import           Data.Maybe (fromMaybe)
import           Data.Text (Text)
import           GHC.Stack (HasCallStack)
import qualified Data.Map.Strict as M (elems)
import qualified Data.Text as T
import qualified Data.Text.IO as T (hPutStr, hPutStrLn, readFile)
import           System.IO (Handle, hFlush, hShow)


{-# ANN module ("HLint: ignore Use camelCase" :: String) #-}


-----


logNotice :: Text -> Text -> MudStack ()
logNotice = L.logNotice "Mud.Threads.Server"


-- ==================================================


{-
CurryMUD doesn't send GA or EOR. Furthermore, prompts always end with a newline character.
This prompting and handle-flushing scheme (implemented below) produces an experience that looks the same on both Mudlet
and TinTin+++. Other options were tried (such as one-line prompts with GA), but this approach produces the most
consistency.
-}


threadServer :: HasCallStack => Handle -> Id -> MsgQueue -> InacTimerQueue -> MudStack ()
threadServer h i mq itq = handle (threadExHandler (Just i) "server") $ setThreadType (Server i) >> loop False
  where
    loop isDropped = mq |&| liftIO . atomically . readTQueue >=> \case
      AsSelf     msg -> handleFromClient i mq itq True msg  >> loop     isDropped
      BlankLine      -> handleBlankLine h                   >> loop     isDropped
      Dropped        -> sayonara True
      FromClient msg -> handleFromClient i mq itq False msg >> loop     isDropped
      FromServer msg -> handleFromServer i h Plaに msg      >> loop     isDropped
      InacBoot       -> sendInacBootMsg h                   >> sayonara isDropped
      InacSecs secs  -> setInacSecs itq secs                >> loop     isDropped
      InacStop       -> stopInacTimer itq                   >> loop     isDropped
      MsgBoot msg    -> sendBootMsg h msg                   >> sayonara isDropped
      Peeped  msg    -> (liftIO . T.hPutStr h $ msg)        >> loop     isDropped
      Prompt p       -> promptHelper i h p                  >> loop     isDropped
      Quit           -> cowbye h                            >> sayonara isDropped
      ShowHandle     -> handleShowHandle i h                >> loop     isDropped
      Shutdown       -> shutDown                            >> loop     isDropped
      SilentBoot     ->                                        sayonara isDropped
      FinishedSpirit -> nonSpiritEgress isDropped
      FinishedEgress -> unit
      ToNpc msg      -> handleFromServer i h Npcに msg      >> loop isDropped
    sayonara isDropped = let f = const $ throwWaitSpiritTimer i >> loop isDropped
                         in views (plaTbl.ind i.spiritAsync) (maybe (nonSpiritEgress isDropped) f) =<< getState
    nonSpiritEgress isDropped = isAdHoc i <$> getState >>= \iah -> do
        stopInacTimer itq
        ((>>) <$> handleEgress i mq <*> unless iah . loop) isDropped


handleBlankLine :: HasCallStack => Handle -> MudStack ()
handleBlankLine h = liftIO $ T.hPutStr h theNl >> hFlush h


handleFromClient :: HasCallStack => Id -> MsgQueue -> InacTimerQueue -> Bool -> Text -> MudStack ()
handleFromClient i mq itq isAsSelf = go
  where
    go (T.strip . stripControl -> msg') = getState >>= \ms ->
        let p                  = getPla i ms
            poss               = p^.possessing
            thruCentral        = msg' |#| interpret i p centralDispatch . headTail . T.words
            helper dflt        = maybe dflt thruOther . getInterp i $ ms
            thruOther f        = interpret (fromMaybe i poss) p f (()# msg' ? ("", []) :? (headTail . T.words $ msg'))
            forwardToNpc npcId = let npcMq = getNpcMsgQueue npcId ms
                                 in liftIO . atomically . writeTQueue npcMq . ExternCmd mq (p^.columns) $ msg'
        in isAsSelf ? thruCentral :? maybe (helper thruCentral) forwardToNpc poss
      where
        interpret asId p f (cn, as) = do forwardToPeepers i (p^.peepers) FromThePeeped msg'
                                         liftIO . atomically . writeTMQueue itq $ ResetInacTimer
                                         f cn . WithArgs asId mq (p^.columns) $ as


forwardToPeepers :: HasCallStack => Id -> Inv -> ToOrFromThePeeped -> Text -> MudStack ()
forwardToPeepers i peeperIds toOrFrom msg = liftIO . atomically . helper =<< getState
  where
    helper ms     = forM_ [ getMsgQueue peeperId ms | peeperId <- peeperIds ] (`writeTQueue` (mkPeepedMsg . getSing i $ ms))
    mkPeepedMsg s = Peeped $ case toOrFrom of
      ToThePeeped   ->      T.concat $ toPeepedColor   : rest
      FromThePeeped -> nl . T.concat $ fromPeepedColor : rest
      where
        rest = [ spaced . bracketQuote $ s, dfltColor, " ", msg ]


handleFromServer :: HasCallStack => Id -> Handle -> ToWhom -> Text -> MudStack ()
handleFromServer _ h Npcに msg = fromServerHelper h $ colorWith toNpcColor " " |<>| msg
handleFromServer i h Plaに msg = getState >>= \ms ->
    forwardToPeepers i (getPeepers i ms) ToThePeeped msg >> fromServerHelper h msg


fromServerHelper :: HasCallStack => Handle -> Text -> MudStack ()
fromServerHelper h t = liftIO $ T.hPutStr h t >> hFlush h


sendInacBootMsg :: HasCallStack => Handle -> MudStack ()
sendInacBootMsg h = liftIO . T.hPutStrLn h . nl . colorWith bootMsgColor $ inacBootMsg


setInacSecs :: HasCallStack => InacTimerQueue -> Seconds -> MudStack ()
setInacSecs itq = liftIO . atomically . writeTMQueue itq . SetInacTimerDur


sendBootMsg :: HasCallStack => Handle -> Text -> MudStack ()
sendBootMsg h = liftIO . T.hPutStrLn h . nl . colorWith bootMsgColor


promptHelper :: HasCallStack => Id -> Handle -> Text -> MudStack ()
promptHelper i h t = sequence_ [ handleFromServer i h Plaに . nl $ t, liftIO . hFlush $ h ]


handleShowHandle :: HasCallStack => Id -> Handle -> MudStack ()
handleShowHandle i h = getMsgQueueColumns i <$> getState >>= \pair ->
    uncurry wrapSend1Nl pair . T.pack =<< liftIO (hShow h)


cowbye :: HasCallStack => Handle -> MudStack ()
cowbye h = liftIO takeADump `catch` fileIOExHandler "cowbye"
  where
    takeADump = T.hPutStrLn h =<< T.readFile =<< mkMudFilePath cowbyeFileFun


shutDown :: HasCallStack => MudStack ()
shutDown = massMsg SilentBoot >> onNewThread commitSuicide
  where
    commitSuicide = do liftIO . mapM_ wait . M.elems . view talkAsyncTbl =<< getState
                       logNotice "shutDown commitSuicide" "everyone has been disconnected."
                       stopNpcActs
                       stopBiodegraders
                       stopRmFuns
                       massPauseEffects
                       pauseCorpseDecomps
                       stopNpcRegens
                       stopNpcDigesters
                       stopNpcServers
                       persist
                       logNotice "shutDown commitSuicide" "killing the listen thread."
                       liftIO . maybeVoid killThread . getListenThreadId =<< getState
