{-# LANGUAGE OverloadedStrings, ViewPatterns #-}

module Mud.Data.State.Util.Random ( dropRndmElems
                                  , percentRange
                                  , rndmDo
                                  , rndmDo_
                                  , rndmDos
                                  , rndmElem
                                  , rndmIntToElem
                                  , rndmIntToPer
                                  , rndmIntToRange
                                  , rndmIntToRangeHelper
                                  , rndmInts
                                  , rndmPer
                                  , rndmR
                                  , rndmRs
                                  , rndmVector ) where

import           Mud.Data.State.MudData
import           Mud.Util.List
import qualified Mud.Util.Misc as U (blowUp)
import           Mud.Util.Misc hiding (blowUp)
import           Mud.Util.Operators
import           Mud.Util.Text

import           Control.Lens (view)
import           Control.Monad (replicateM)
import           Control.Monad.IO.Class (liftIO)
import           Control.Monad.Reader (ask)
import           Data.Ix (inRange)
import qualified Data.Vector.Unboxed as V (Vector, (!), toList)
import           System.Random.MWC (GenIO, uniformR, uniformVector)


blowUp :: BlowUp a
blowUp = U.blowUp "Mud.Data.State.Util.Random"


-- ==================================================


type Count = Int


dropRndmElems :: V.Vector Int -> Count -> [a] -> [a]
dropRndmElems v = helper
  where
    helper 0 xs = xs
    helper n xs = helper (pred n) $ let i = rndmIntToRange (v V.! n) (0, length xs - 1)
                                    in dropElemAt i xs


getGen :: MudStack GenIO
getGen = view gen <$> ask


isSuccess :: Int -> MudStack Bool
isSuccess prob = inRange (1, adjust prob) <$> rndmPer
  where
    adjust p = p < 1 ? 1 :? p


percentRange :: Range
percentRange = (1, 100)


rndmDo :: Int -> Fun -> MudStack Bool
rndmDo prob f = mIf (isSuccess prob) (f >> return True) . return $ False


rndmDo_ :: Int -> Fun -> MudStack ()
rndmDo_ prob = mWhen (isSuccess prob)


rndmDos :: [(Int, MudStack ())] -> MudStack ()
rndmDos []             = unit
rndmDos ((prob, f):xs) = mIf (isSuccess prob) f . rndmDos $ xs


rndmElem :: [a] -> MudStack a
rndmElem xs = (xs !!) <$> rndmR (0, length xs - 1)


rndmInts :: Int -> MudStack [Int]
rndmInts c = V.toList <$> rndmVector c


rndmIntToElem :: Int -> [a] -> a
rndmIntToElem r xs = xs !! rndmIntToRange r (0, length xs - 1)


rndmIntToPer :: Int -> Int
rndmIntToPer = flip rndmIntToRange percentRange


rndmIntToRange :: Int -> Range -> Int
rndmIntToRange = rndmIntToRangeHelper maxBound


rndmIntToRangeHelper :: Int -> Int -> Range -> Int
rndmIntToRangeHelper m (abs -> r) pair@(x, y)
  | x < 0     = oops
  | y < x     = oops
  | x == y    = x
  | otherwise = let steps   = y - x + 1
                    stepAmt = m `div` steps
                    helper step z | r <= z + stepAmt = step
                                  | otherwise        = helper (succ step) $ z + stepAmt
                in x + helper 0 0
  where
    oops = blowUp "rndmIntToRangeHelper" "bad range" . showText $ pair


rndmPer :: MudStack Int
rndmPer = rndmR percentRange


rndmR :: Range -> MudStack Int
rndmR r = liftIO . uniformR r =<< getGen


rndmRs :: Count -> Range -> MudStack [Int]
rndmRs c = replicateM c . rndmR


rndmVector :: Count -> MudStack (V.Vector Int)
rndmVector c = flip uniformVector c =<< getGen
