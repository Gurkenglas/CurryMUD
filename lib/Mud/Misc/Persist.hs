{-# LANGUAGE OverloadedStrings #-}

module Mud.Misc.Persist (persist) where

import           Mud.Cmds.Msgs.Misc
import           Mud.Data.State.MudData
import           Mud.Data.State.Util.Locks
import           Mud.Data.State.Util.Misc
import qualified Mud.Misc.Logging as L (logExMsg, logNotice)
import           Mud.Threads.Misc
import           Mud.TopLvlDefs.FilePaths
import           Mud.TopLvlDefs.Misc
import           Mud.Util.Misc

import           Control.Concurrent.Async (wait, withAsync)
import           Control.Exception (SomeException)
import           Control.Exception.Lifted (catch)
import           Control.Lens (views)
import           Control.Lens.Operators ((^.))
import           Control.Monad (when)
import           Control.Monad.IO.Class (liftIO)
import           Control.Monad.Trans.Resource (runResourceT)
import           Data.Aeson (encode, toJSON)
import           Data.Conduit (($$), (=$), yield)
import           Data.List (sort)
import           Data.Text (Text)
import           Data.Tuple (swap)
import qualified Data.ByteString.Lazy as LB (toStrict)
import qualified Data.Conduit.Binary as CB (sinkFile)
import qualified Data.Conduit.List as CL (map)
import qualified Data.IntMap.Strict as IM (fromList, map)
import qualified Data.Map.Strict as M (toList)
import qualified Data.Text as T
import           System.Directory (createDirectory, doesDirectoryExist, getDirectoryContents, removeDirectoryRecursive)
import           System.FilePath ((</>))


logExMsg :: Text -> Text -> SomeException -> MudStack ()
logExMsg = L.logExMsg "Mud.Misc.Persist"


logNotice :: Text -> Text -> MudStack ()
logNotice = L.logNotice "Mud.Misc.Persist"


-- ==================================================


persist :: MudStack ()
persist = do logNotice "persist" "persisting the world."
             pair <- (,) <$> getLock persistLock <*> getState
             liftIO (uncurry persistHelper pair) `catch` persistExHandler


persistHelper :: Lock -> MudState -> IO ()
persistHelper l ms = withLock l $ do
    dir  <- mkMudFilePath persistDirFun
    path <- getNonExistingPath =<< (dir </>) . T.unpack . T.replace ":" "-" <$> mkTimestamp
    createDirectory path
    cont <- dropIrrelevantFiles . sort <$> getDirectoryContents dir
    when (length cont > noOfPersistedWorlds) . removeDirectoryRecursive . (dir </>) . head $ cont
    flip withAsync wait $ mapM_ runResourceT [ write (ms^.armTbl                ) $ path </> armTblFile
                                             , write (ms^.chanTbl               ) $ path </> chanTblFile
                                             , write (ms^.clothTbl              ) $ path </> clothTblFile
                                             , write (ms^.coinsTbl              ) $ path </> coinsTblFile
                                             , write (ms^.conTbl                ) $ path </> conTblFile
                                             , write (ms^.corpseTbl             ) $ path </> corpseTblFile
                                             , write (ms^.entTbl                ) $ path </> entTblFile
                                             , write eqTblHelper                  $ path </> eqTblFile
                                             , write (ms^.foodTbl               ) $ path </> foodTblFile
                                             , write (ms^.holySymbolTbl         ) $ path </> holySymbolTblFile
                                             , write (ms^.hostTbl               ) $ path </> hostTblFile
                                             , write (ms^.invTbl                ) $ path </> invTblFile
                                             , write (ms^.lightTbl              ) $ path </> lightTblFile
                                             , write (ms^.mobTbl                ) $ path </> mobTblFile
                                             , write (ms^.objTbl                ) $ path </> objTblFile
                                             , write (ms^.pausedCorpseDecompsTbl) $ path </> pausedCorpseDecompsTblFile
                                             , write (ms^.pausedEffectTbl       ) $ path </> pausedEffectTblFile
                                             , write (ms^.pcSingTbl             ) $ path </> pcSingTblFile
                                             , write (ms^.pcTbl                 ) $ path </> pcTblFile
                                             , write (ms^.plaTbl                ) $ path </> plaTblFile
                                             , write (ms^.rmTbl                 ) $ path </> rmTblFile
                                             , write (ms^.rmTeleNameTbl         ) $ path </> rmTeleNameTblFile
                                             , write (ms^.rndmNamesMstrTbl      ) $ path </> rndmNamesMstrTblFile
                                             , write (ms^.teleLinkMstrTbl       ) $ path </> teleLinkMstrTblFile
                                             , write (ms^.typeTbl               ) $ path </> typeTblFile
                                             , write (ms^.vesselTbl             ) $ path </> vesselTblFile
                                             , write (ms^.wpnTbl                ) $ path </> wpnTblFile
                                             , write (ms^.writableTbl           ) $ path </> writableTblFile ]
  where
    getNonExistingPath path = mIf (doesDirectoryExist path)
                                  (getNonExistingPath $ path ++ "_")
                                  (return path)
    write tbl file          = yield (toJSON tbl) $$ CL.map (LB.toStrict . encode) =$ CB.sinkFile file
    eqTblHelper             = views eqTbl (IM.map (IM.fromList . map swap . M.toList)) ms


persistExHandler :: SomeException -> MudStack ()
persistExHandler e = do logExMsg "persistExHandler" (rethrowExMsg "while persisting the world") e
                        throwToListenThread e
