{-# LANGUAGE TupleSections, ViewPatterns #-}

module MudTests.Data.State.Util.Random where

import           Mud.Cmds.Util.Misc
import           Mud.Data.State.Util.Random
import           MudTests.TestUtil

import           Data.Ix (inRange)
import qualified Data.Vector.Unboxed as V (elem, head, map)
import           Test.QuickCheck.Monadic (assert, monadicIO)
import           Test.Tasty.QuickCheck (Property, choose, forAll)

prop_dropRndmElems :: Property
prop_dropRndmElems = forAll (choose (1, 1000)) $ \c ->
    monadicIO $ do (v, xs) <- inWorld $ (,) <$> rndmVector (succ c) <*> rndmInts c
                   let xs' = dropRndmElems v c xs
                   assert $ length xs' == length xs - c

prop_rndmIntToRange_withinRangeFromZero :: Property
prop_rndmIntToRange_withinRangeFromZero = forAll (choose percentRange) $ \((0, ) -> range) ->
    monadicIO $ do r <- inWorld (V.head <$> mkRndmVector)
                   assert . inRange range . rndmIntToRange r $ range

prop_rndmIntToRange_withinRangeFromOther :: Property
prop_rndmIntToRange_withinRangeFromOther = forAll (choose (5, 10)) $ \x -> let range = (x, x + 10) in
    monadicIO $ do r <- inWorld (V.head <$> mkRndmVector)
                   assert . inRange range . rndmIntToRange r $ range

prop_rndmIntToRange_distribution :: Property
prop_rndmIntToRange_distribution = monadicIO $ do v <- V.map (`rndmIntToRange` (50, 100)) <$> inWorld (rndmVector 1000)
                                                  assert . and $ [ x `V.elem` v | x <- [50..100] ]

prop_rndmIntToRangeHelper_lowMax :: Property
prop_rndmIntToRangeHelper_lowMax = let range = (1, 10) in forAll (choose (0, 100)) $ \r ->
    monadicIO . assert . inRange range . rndmIntToRangeHelper 100 r $ range

prop_rndmRs_withinRange :: Property
prop_rndmRs_withinRange = forAll (choose percentRange) $ \((1, ) -> range) ->
    monadicIO $ assert . all (inRange range) =<< (inWorld . rndmRs 100 $ range)

prop_rndmRs_noRange :: Property
prop_rndmRs_noRange = forAll (choose percentRange) $ \x ->
    monadicIO $ assert . all (== x) =<< (inWorld . rndmRs 100 $ (x, x))

prop_rndmRs_minimalRange :: Property
prop_rndmRs_minimalRange = forAll (choose percentRange) $ \x@((+ 1) -> y) ->
    monadicIO $ assert . all (== x) . filter (/= y) =<< (inWorld . rndmRs 100 $ (x, y))
