{-# LANGUAGE FlexibleContexts, LambdaCase, OverloadedStrings, RecordWildCards, ViewPatterns #-}

module Mud.TheWorld.Misc ( commonHooks
                         , commonRmActionFuns
                         , lookTrashHook
                         , mkGenericHookFun
                         , mkRndmBcastRmFun
                         , putTrashHook
                         , trashRmAction ) where

import           Mud.Cmds.Msgs.Advice
import           Mud.Cmds.Msgs.Dude
import           Mud.Cmds.Msgs.Sorry
import           Mud.Cmds.Util.Pla
import           Mud.Data.Misc
import           Mud.Data.State.ActionParams.ActionParams
import           Mud.Data.State.MudData
import           Mud.Data.State.Util.Coins
import           Mud.Data.State.Util.Get
import           Mud.Data.State.Util.Misc
import           Mud.Data.State.Util.Output
import           Mud.Data.State.Util.Random
import           Mud.Misc.LocPref
import qualified Mud.Misc.Logging as L (logNotice, logPlaOut)
import           Mud.Misc.Misc
import           Mud.TheWorld.Zones.AdminZoneIds (iTrashDump)
import           Mud.Threads.Misc
import           Mud.TopLvlDefs.Seconds
import qualified Mud.Util.Misc as U (pmf)
import           Mud.Util.Misc hiding (pmf)
import           Mud.Util.Operators
import           Mud.Util.Quoting
import           Mud.Util.Text

import           Control.Exception.Lifted (catch, handle)
import           Control.Lens (_1, _2, _3, _4)
import           Control.Lens.Operators ((.~), (&), (%~), (<>~))
import           Control.Monad ((>=>), unless)
import           Control.Monad.IO.Class (liftIO)
import           Data.List ((\\), foldl')
import           Data.Monoid ((<>))
import           Data.Text (Text)
import qualified Data.Text as T


pmf :: PatternMatchFail
pmf = U.pmf "Mud.TheWorld.Misc"


-----


logNotice :: Text -> Text -> MudStack ()
logNotice = L.logNotice "Mud.TheWorld.Misc"


logPlaOut :: Text -> Id -> [Text] -> MudStack ()
logPlaOut = L.logPlaOut "Mud.TheWorld.Misc"


-- ==================================================
-- Common hooks:


commonHooks :: [(HookName, HookFun)]
commonHooks = [ (lookTrashHookName, lookTrashHookFun)
              , (putTrashHookName,  putTrashHookFun ) ]


-----


lookTrashHook :: Hook
lookTrashHook = Hook lookTrashHookName [ "trash", "bin" ]


lookTrashHookName :: HookName
lookTrashHookName = "(common)_lookTrash"


lookTrashHookFun :: HookFun
lookTrashHookFun = mkGenericHookFun trashDesc "looks at the trash bin." "looked at trash bin"
  where
    trashDesc = "The trash bin is an oblong metal container, about 3 feet tall, with a lid connected to the body by \
                \hinges. Affixed to the lid is a bronze plate, on which the following has been neatly etched:\n\
                \\"Magic Trash Bin: you may dispose of unwanted items by 'trash'ing them here. Items placed in this \
                \bin are magically expunged, and entirely unrecoverable.\n\
                \Thank you for keeping Lop'len-ko clean.\"\n\
                \Carefully lifting open the lid and peaking inside, you find only an ominous darkness; not even the \
                \bottom of the bin is visible."


mkGenericHookFun :: Text -> Text -> Text -> HookFun
mkGenericHookFun toSelf bcastTxt logMsgTxt = f
  where
    f i Hook { .. } _ a@(_, (ms, _, _, _), _) =
        let selfDesig = mkStdDesig i ms DoCap
        in a &    _1 %~  (\\ hookTriggers)
             & _2._2 <>~ pure toSelf
             & _2._3 <>~ pure (serialize selfDesig |<>| bcastTxt, desigOtherIds selfDesig)
             & _2._4 <>~ pure (bracketQuote hookName |<>| parseInBandsSuffix i ms logMsgTxt)


-----


putTrashHook :: Hook
putTrashHook = Hook putTrashHookName [ "trash", "bin" ]


putTrashHookName :: HookName
putTrashHookName = "(common)_putTrash"


putTrashHookFun :: HookFun
putTrashHookFun i _ _ a@(as, (ms, _, _, _), _) = let (gir, fs) = trashHelper i ms as
                                                 in a & _2 .~ gir & _3 .~ fs


trashHelper :: Id -> MudState -> Args -> (GenericIntermediateRes, Funs)
trashHelper i ms as =
    let (inInvs, inEqs, inRms)  = sortArgsInvEqRm InInv as
        sorryInEq               = inEqs |!| sorryTrashInEq
        sorryInRm               = inRms |!| sorryTrashInRm
        invCoins                = getInvCoins i ms
        d                       = mkStdDesig  i ms DoCap
        (eiss, ecs)             = uncurry (resolveMobInvCoins i ms inInvs) invCoins
        (ms', toSelfs, bs)      = foldl' (helperTrashEitherInv   i d) (ms,  [],      []         ) eiss
        gir                     =         helperTrashEitherCoins i d  (ms', toSelfs, bs, toSelfs) ecs
        gir'@(_, _, _, logMsgs) = (gir &) $ if ()# invCoins
                                    then _2 .~ pure dudeYourHandsAreEmpty
                                    else _2 %~ (dropBlanks [ sorryInEq, sorryInRm ] ++)
    in (gir', logMsgs |!| pure f)
  where
    f = rndmDo_ 10 $ let msg = "The lid of the trash bin momentarily opens of its own accord as a loud belch is emitted \
                               \from inside the container."
                     in rndmR (1, 4) >>= \secs -> do
                            liftIO . delaySecs $ secs
                            getState >>= \ms' -> bcastNl . pure $ (msg, findMobIds ms' . getMobRmInv i $ ms')


-- ==================================================
-- Common room action functions:


commonRmActionFuns :: [(FunName, RmActionFun)]
commonRmActionFuns = pure (trashRmActionFunName, trash)


-----


trashRmAction :: RmAction
trashRmAction = RmAction "trash" trashRmActionFunName


trashRmActionFunName :: FunName
trashRmActionFunName = "(common)_trash"


trash :: RmActionFun
trash p@AdviseNoArgs          = advise p [] adviceTrashNoArgs
trash (LowerNub i mq cols as) = helper |&| modifyState >=> \((toSelfs, bs, logMsgs), fs) -> do
    logMsgs |#| logPlaOut "trash" i
    multiWrapSend mq cols toSelfs
    bcastIfNotIncogNl i bs
    sequence_ fs
  where
    helper ms = let ((ms', toSelfs, bs, logMsgs), fs) = trashHelper i ms as in (ms', ((toSelfs, bs, logMsgs), fs))
trash p = pmf "trash" p


helperTrashEitherInv :: Id
                    -> Desig
                    -> (MudState, [Text], [Broadcast])
                    -> Either Text Inv
                    -> (MudState, [Text], [Broadcast])
helperTrashEitherInv i d a@(ms, _, _) = \case
  Left  msg -> a & _2 <>~ pure msg
  Right is  -> let (toSelfs, bs) = mkTrashInvDescs i ms d is
               in a & _1.invTbl.ind i          %~  (\\ is)
                    & _1.invTbl.ind iTrashDump %~  addToInv ms is
                    & _2                       <>~ toSelfs
                    & _3                       <>~ bs


mkTrashInvDescs :: Id -> MudState -> Desig -> Inv -> ([Text], [Broadcast])
mkTrashInvDescs i ms d (mkNameCountBothList i ms -> ncbs) = unzip . map helper $ ncbs
  where
    helper (_, c, (s, _)) | c == 1 =
        ("You place the " <> s <> rest, (T.concat [ serialize d, " places ", aOrAn s, rest ], desigOtherIds d))
    helper (_, c, b) =
        ("You place " <> rest', (serialize d <> " places " <> rest', desigOtherIds d))
      where
        rest' = T.concat [ showTxt c, " ", mkPlurFromBoth b, rest ]
    rest = " into the trash bin."


helperTrashEitherCoins :: Id
                       -> Desig
                       -> GenericIntermediateRes
                       -> [Either [Text] Coins]
                       -> GenericIntermediateRes
helperTrashEitherCoins i d (ms, toSelfs, bs, logMsgs) ecs =
    let (ms', toSelfs', logMsgs', c) = foldl' helper (ms, toSelfs, logMsgs, mempty) ecs
    in (ms', toSelfs', bs ++ mkTrashCoinsDescOthers d c, logMsgs')
  where
    helper a = \case
      Left  msgs -> a & _2 <>~ msgs
      Right c    -> let toSelfs' = mkTrashCoinsDescsSelf c
                    in a & _1.coinsTbl.ind i          %~  (<> negateCoins c)
                         & _1.coinsTbl.ind iTrashDump %~  (<>             c)
                         & _2                         <>~ toSelfs'
                         & _3                         <>~ toSelfs'
                         & _4                         <>~ c


mkTrashCoinsDescOthers :: Desig -> Coins -> [Broadcast]
mkTrashCoinsDescOthers d c =
  c |!| [ (T.concat [ serialize d, " deposits ", aCoinSomeCoins c, " into the trash bin." ], desigOtherIds d) ]


mkTrashCoinsDescsSelf :: Coins -> [Text]
mkTrashCoinsDescsSelf = mkCoinsMsgs helper
  where
    helper 1 cn = T.concat [ "You deposit ", aOrAn cn,            " into the trash bin." ]
    helper a cn = T.concat [ "You deposit ", showTxt a, " ", cn, "s into the trash bin." ]


-- ==================================================
-- Other:


-- If "prob" is 25 (1 in 4), and "secs" is 60, we can expect the event to occur once every 4 mins.
mkRndmBcastRmFun :: Id -> Text -> FunName -> Int -> Seconds -> Text -> Fun
mkRndmBcastRmFun i idName fn prob secs msg = handle (threadExHandler (Just i) threadName) $ do
    setThreadType . RmFun $ i
    logNotice fn . T.concat $ [ "room function started for ", idName, " ", parensQuote . showTxt $ i, "." ]
    loop `catch` die Nothing threadName
  where
    threadName = T.concat [ "room function ", dblQuote fn, " ", idName ]
    loop       = getState >>= \ms -> let is = filter (`isNpcPla` ms) . getInv i $ ms in do
        unless (()# is) . rndmDo_ prob . bcastNl . pure $ (msg, is)
        liftIO . delaySecs $ secs
        loop
