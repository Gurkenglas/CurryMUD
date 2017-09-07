{-# LANGUAGE OverloadedStrings #-}

module Mud.TheWorld.Liqs ( liqList
                         , oilLiq
                         , oilTag
                         , potDxLiq
                         , potFpLiq
                         , potFpTag
                         , potHpLiq
                         , potHpTag
                         , potHtLiq
                         , potInstantDxLiq
                         , potInstantDxTag
                         , potInstantFpLiq
                         , potInstantHpLiq
                         , potInstantHtLiq
                         , potInstantHtTag
                         , potInstantMaLiq
                         , potInstantMaTag
                         , potInstantMpLiq
                         , potInstantPpLiq
                         , potInstantPsLiq
                         , potInstantPsTag
                         , potInstantStLiq
                         , potInstantStTag
                         , potInstantTinnitusLiq
                         , potMaLiq
                         , potMpLiq
                         , potMpTag
                         , potPpLiq
                         , potPpTag
                         , potPsLiq
                         , potStLiq
                         , potTinnitusLiq
                         , potTinnitusTag
                         , waterLiq
                         , waterTag ) where

import Mud.Cmds.Msgs.Misc
import Mud.Data.State.MudData
import Mud.TheWorld.LiqIds
import Mud.TopLvlDefs.Misc
import Mud.TopLvlDefs.Seconds
import Mud.Util.Misc
import Mud.Util.Text

import Data.Monoid ((<>))
import Data.Text (Text)


liqList :: [(Id, DistinctLiq, Liq)]
liqList = [ (iLiqOil,                oilDistinctLiq,                oilLiq               )
          , (iLiqWater,              waterDistinctLiq,              waterLiq             )
          , (iLiqPotHp,              potHpDistinctLiq,              potHpLiq             )
          , (iLiqPotInstantHp,       potInstantHpDistinctLiq,       potInstantHpLiq      )
          , (iLiqPotMp,              potMpDistinctLiq,              potMpLiq             )
          , (iLiqPotInstantMp,       potInstantMpDistinctLiq,       potInstantMpLiq      )
          , (iLiqPotPp,              potPpDistinctLiq,              potPpLiq             )
          , (iLiqPotInstantPp,       potInstantPpDistinctLiq,       potInstantPpLiq      )
          , (iLiqPotFp,              potFpDistinctLiq,              potFpLiq             )
          , (iLiqPotInstantFp,       potInstantFpDistinctLiq,       potInstantFpLiq      )
          , (iLiqPotSt,              potStDistinctLiq,              potStLiq             )
          , (iLiqPotInstantSt,       potInstantStDistinctLiq,       potInstantStLiq      )
          , (iLiqPotDx,              potDxDistinctLiq,              potDxLiq             )
          , (iLiqPotInstantDx,       potInstantDxDistinctLiq,       potInstantDxLiq      )
          , (iLiqPotHt,              potHtDistinctLiq,              potHtLiq             )
          , (iLiqPotInstantHt,       potInstantHtDistinctLiq,       potInstantHtLiq      )
          , (iLiqPotMa,              potMaDistinctLiq,              potMaLiq             )
          , (iLiqPotInstantMa,       potInstantMaDistinctLiq,       potInstantMaLiq      )
          , (iLiqPotPs,              potPsDistinctLiq,              potPsLiq             )
          , (iLiqPotInstantPs,       potInstantPsDistinctLiq,       potInstantPsLiq      )
          , (iLiqPotTinnitus,        potTinnitusDistinctLiq,        potTinnitusLiq       )
          , (iLiqPotInstantTinnitus, potInstantTinnitusDistinctLiq, potInstantTinnitusLiq) ]


-----


oilLiq :: Liq
oilLiq = Liq (DistinctLiqId iLiqOil)
             (Don'tArticle "oil")
             "There is a decidedly fishy smell with nutty overtones."
             "The heavy, greasy oil isn't appetizing in the least."
             "The unquestionably disagreeable taste of the lamp oil suggests that it might not be entirely suitable for \
             \consumption. You suppress the urge to gag."


oilDistinctLiq :: DistinctLiq
oilDistinctLiq = DistinctLiq "oil" EdibleEffects { _digestEffects  = Just de
                                                 , _consumpEffects = Nothing }
  where
    de = EffectList . pure . Left $ ie
    ie = InstaEffect { _instaEffectSub     = InstaEffectOther oilTag
                     , _instaEffectVal     = Nothing
                     , _instaEffectFeeling = mkPotEffectFeeling oilTag }


oilTag :: FeelingTag
oilTag = "oil"


-----


waterLiq :: Liq
waterLiq = Liq (DistinctLiqId iLiqWater)
               (Don'tArticle "water")
               "The water is entirely odorless."
               "The water is entirely tasteless."
               "The cool, clear water feels refreshing as it goes down."


waterDistinctLiq :: DistinctLiq
waterDistinctLiq = DistinctLiq "water" EdibleEffects { _digestEffects  = Just de
                                                     , _consumpEffects = Nothing }
  where
    de = EffectList . pure . Left $ ie
    ie = InstaEffect { _instaEffectSub     = MobInstaEffectPts Fp
                     , _instaEffectVal     = Just . EffectFixedVal $ 2
                     , _instaEffectFeeling = Just . EffectFeeling waterTag $ foodWaterFeelDur }


waterTag :: FeelingTag
waterTag = "water"


-----


potHpLiq :: Liq
potHpLiq = Liq (DistinctLiqId iLiqPotHp)
               (DoArticle "milky, off-white liquid")
               "A bitterly pungent smell bombards you."
               "You imagine that the rind of some intolerably bitter, inedible fruit might taste like this."
               "The distinctly acrid taste is making this difficult."


potHpDistinctLiq :: DistinctLiq
potHpDistinctLiq = DistinctLiq "pot_HP" EdibleEffects { _digestEffects  = Just de
                                                      , _consumpEffects = Nothing }
  where
    de = EffectList . pure . Left $ ie
    ie = InstaEffect { _instaEffectSub     = MobInstaEffectPts Hp
                     , _instaEffectVal     = Just . EffectFixedVal $ potXpEffectVal
                     , _instaEffectFeeling = mkPotEffectFeeling potHpTag }


potXpEffectVal :: Int
potXpEffectVal = 2


mkPotEffectFeeling :: FeelingTag -> Maybe EffectFeeling
mkPotEffectFeeling = Just . (`EffectFeeling` potFeelDur)


potHpTag :: Text
potHpTag = "potHp"


potInstantHpLiq :: Liq
potInstantHpLiq = Liq (DistinctLiqId iLiqPotInstantHp)
                      (DoArticle "murky, rust-colored liquid")
                      "Almost immediately your nostrils burn and your eyes water in reaction to the tonic's metallic \
                      \bouquet."
                      "The caustic taste nearly causes you to gag."
                      "Ugh! The potion is truly revolting. Concentrating, you will yourself to keep it down."


potInstantHpDistinctLiq :: DistinctLiq
potInstantHpDistinctLiq = DistinctLiq "pot_insta_HP" EdibleEffects { _digestEffects  = Nothing
                                                                   , _consumpEffects = Just ce }
  where
    ce = mkPotConsumpEffects es
    es = EffectList . pure . Left $ ie
    ie = InstaEffect { _instaEffectSub     = MobInstaEffectPts Hp
                     , _instaEffectVal     = Just . EffectRangedVal $ potInstantXpEffectRange
                     , _instaEffectFeeling = mkPotEffectFeeling potHpTag }


mkPotConsumpEffects :: EffectList -> ConsumpEffects
mkPotConsumpEffects = ConsumpEffects 4 {- mouthfuls -} 30 {- secs -}


potInstantXpEffectRange :: Range
potInstantXpEffectRange = (8, 12)


-----


potMpLiq :: Liq
potMpLiq = Liq (DistinctLiqId iLiqPotMp)
               (DoArticle "cloudy, semi-transparent liquid")
               noSmellMsg
               "Save for a nearly undetectable chalkiness, the liquid is tasteless."
               "The cloudy liquid goes down like water."


potMpDistinctLiq :: DistinctLiq
potMpDistinctLiq = DistinctLiq "pot_MP" EdibleEffects { _digestEffects  = Just de
                                                      , _consumpEffects = Nothing }
  where
    de = EffectList . pure . Left $ ie
    ie = InstaEffect { _instaEffectSub     = MobInstaEffectPts Mp
                     , _instaEffectVal     = Just . EffectFixedVal $ potXpEffectVal
                     , _instaEffectFeeling = mkPotEffectFeeling potMpTag }

potMpTag :: Text
potMpTag = "potMp"


potInstantMpLiq :: Liq
potInstantMpLiq = Liq (DistinctLiqId iLiqPotInstantMp)
                      (DoArticle "crimson liquid")
                      "There is a fruity smell of strawberries or perhaps raspberries."
                      "The tart taste makes you want to smack your lips."
                      "The juicy, piquant liquid makes a pleasant beverage."


potInstantMpDistinctLiq :: DistinctLiq
potInstantMpDistinctLiq = DistinctLiq "pot_insta_MP" EdibleEffects { _digestEffects  = Nothing
                                                                   , _consumpEffects = Just ce }
  where
    ce = mkPotConsumpEffects es
    es = EffectList . pure . Left $ ie
    ie = InstaEffect { _instaEffectSub     = MobInstaEffectPts Mp
                     , _instaEffectVal     = Just . EffectRangedVal $ potInstantXpEffectRange
                     , _instaEffectFeeling = mkPotEffectFeeling potMpTag }


-----


potPpLiq :: Liq
potPpLiq = Liq (DistinctLiqId iLiqPotPp)
               (DoArticle "shocking pink liquid")
               noSmellMsg
               "The thick, powdery concoction tastes sweet and creamy."
               "Despite its pink color and slight grittiness, the tonic reminds you of sweetened cow milk."


potPpDistinctLiq :: DistinctLiq
potPpDistinctLiq = DistinctLiq "pot_PP" EdibleEffects { _digestEffects  = Just de
                                                      , _consumpEffects = Nothing }
  where
    de = EffectList . pure . Left $ ie
    ie = InstaEffect { _instaEffectSub     = MobInstaEffectPts Pp
                     , _instaEffectVal     = Just . EffectFixedVal $ potXpEffectVal
                     , _instaEffectFeeling = mkPotEffectFeeling potPpTag }


potPpTag :: Text
potPpTag = "potPp"


potInstantPpLiq :: Liq
potInstantPpLiq = Liq (DistinctLiqId iLiqPotInstantPp)
                      (DoArticle "pale yellow liquid")
                      "There is a yeast-like smell that reminds you of freshly-kneaded dough."
                      "You don't taste much until you are hit with a grain-like, malty aftertaste."
                      "The scents of yeast and fermentation fill your nostrils."


potInstantPpDistinctLiq :: DistinctLiq
potInstantPpDistinctLiq = DistinctLiq "pot_insta_PP" EdibleEffects { _digestEffects  = Nothing
                                                                   , _consumpEffects = Just ce }
  where
    ce = mkPotConsumpEffects es
    es = EffectList . pure . Left $ ie
    ie = InstaEffect { _instaEffectSub     = MobInstaEffectPts Pp
                     , _instaEffectVal     = Just . EffectRangedVal $ potInstantXpEffectRange
                     , _instaEffectFeeling = mkPotEffectFeeling potPpTag }


-----


potFpLiq :: Liq
potFpLiq = Liq (DistinctLiqId iLiqPotFp)
               (DoArticle "dark black liquid")
               "The dark black liquid looks as though it could be coffee, but it smells heavily of licorice."
               "The dark black liquid tastes bitingly of licorice and salt."
               "The concoction's briny flavors are far too strong for your tastes."


potFpDistinctLiq :: DistinctLiq
potFpDistinctLiq = DistinctLiq "pot_FP" EdibleEffects { _digestEffects  = Just de
                                                      , _consumpEffects = Nothing }
  where
    de = EffectList . pure . Left $ ie
    ie = InstaEffect { _instaEffectSub     = MobInstaEffectPts Fp
                     , _instaEffectVal     = Just . EffectFixedVal $ potXpEffectVal
                     , _instaEffectFeeling = mkPotEffectFeeling potFpTag }


potFpTag :: Text
potFpTag = "potFp"


potInstantFpLiq :: Liq
potInstantFpLiq = Liq (DistinctLiqId iLiqPotInstantFp)
                      (DoArticle "clear, shimmering liquid")
                      "You sniff the fumes omitted by the clear liquid. The heavy scent is similar to that of alcohol, \
                      \but with sharp, vinegar-like overtones."
                      "You are overwhelmed by a stunning mix of sharp and bitingly bad flavors."
                      "You fight back the urge to gag."


potInstantFpDistinctLiq :: DistinctLiq
potInstantFpDistinctLiq = DistinctLiq "pot_insta_FP" EdibleEffects { _digestEffects  = Nothing
                                                                   , _consumpEffects = Just ce }
  where
    ce = mkPotConsumpEffects es
    es = EffectList . pure . Left $ ie
    ie = InstaEffect { _instaEffectSub     = MobInstaEffectPts Fp
                     , _instaEffectVal     = Just . EffectRangedVal $ potInstantXpEffectRange
                     , _instaEffectFeeling = mkPotEffectFeeling potFpTag }


-----


potStLiq :: Liq
potStLiq = Liq (DistinctLiqId iLiqPotSt)
               (DoArticle "thick, muddy liquid")
               "You detect earthy scents of nuts and grasses in the highly nuanced odors."
               "There is a very starchy taste reminiscent of grass clippings. You sense small, soft lumps in the liquid."
               "The lumpy, viscous liquid is difficult to quaff."


potStDistinctLiq :: DistinctLiq
potStDistinctLiq = DistinctLiq "pot_ST" EdibleEffects { _digestEffects  = Just de
                                                      , _consumpEffects = Nothing }
  where
    de = EffectList . pure . Right $ e
    e  = Effect { _effectTag     = Nothing
                , _effectSub     = EffectAttrib St
                , _effectVal     = Just . EffectFixedVal $ potAttribEffectVal
                , _effectDur     = potAttribEffectDur
                , _effectFeeling = Nothing }


potAttribEffectVal :: Int
potAttribEffectVal = 2


potAttribEffectDur :: Seconds
potAttribEffectDur = fifteenMinsInSecs


potInstantStLiq :: Liq
potInstantStLiq = Liq (DistinctLiqId iLiqPotInstantSt)
                      (DoArticle "brown, frothy liquid")
                      "The liquid's earthy scents are reminiscent of soil and dried leaves."
                      "The taste is on the bitter side. You detect some small, grainy particles dispersed among the liquid."
                      "Though its taste is not particularly pleasing, the concoction goes down easily."


potInstantStDistinctLiq :: DistinctLiq
potInstantStDistinctLiq = DistinctLiq "pot_insta_ST" EdibleEffects { _digestEffects  = Nothing
                                                                   , _consumpEffects = Just ce }
  where
    ce = mkPotConsumpEffects es
    es = EffectList . pure . Right $ e
    e  = Effect { _effectTag     = Just potInstantStTag
                , _effectSub     = EffectAttrib St
                , _effectVal     = Just . EffectRangedVal $ potInstantAtttribEffectRange
                , _effectDur     = potAttribEffectDur
                , _effectFeeling = Nothing }


potInstantStTag :: Text
potInstantStTag = "potInstantSt"


potInstantAtttribEffectRange :: Range
potInstantAtttribEffectRange = (8, 12)


-----


potDxLiq :: Liq
potDxLiq = Liq (DistinctLiqId iLiqPotDx)
               (DoArticle "oily, maroon liquid")
               "A fishy smell bombards you. Gross!"
               "The dense, oily liquid leaves a strong fishy taste in your mouth."
               "The scent of raw fish and the taste of fish oil overwhelm your senses."


potDxDistinctLiq :: DistinctLiq
potDxDistinctLiq = DistinctLiq "pot_DX" EdibleEffects { _digestEffects  = Just de
                                                      , _consumpEffects = Nothing }
  where
    de = EffectList . pure . Right $ e
    e  = Effect { _effectTag     = Nothing
                , _effectSub     = EffectAttrib Dx
                , _effectVal     = Just . EffectFixedVal $ potAttribEffectVal
                , _effectDur     = potAttribEffectDur
                , _effectFeeling = Nothing }


potInstantDxLiq :: Liq
potInstantDxLiq = Liq (DistinctLiqId iLiqPotInstantDx)
                      (DoArticle "heavy, translucent liquid")
                      "There is a distinctly acidic aroma of lemon and lime."
                      "The liquid, though colorless, is rather thick, and has a notably acidic aftertaste."
                      "The dense tonic is oddly tart. Your eyes water slightly."


potInstantDxDistinctLiq :: DistinctLiq
potInstantDxDistinctLiq = DistinctLiq "pot_insta_DX" EdibleEffects { _digestEffects  = Nothing
                                                                   , _consumpEffects = Just ce }
  where
    ce = mkPotConsumpEffects es
    es = EffectList . pure . Right $ e
    e  = Effect { _effectTag     = Just potInstantDxTag
                , _effectSub     = EffectAttrib Dx
                , _effectVal     = Just . EffectRangedVal $ potInstantAtttribEffectRange
                , _effectDur     = potAttribEffectDur
                , _effectFeeling = Nothing }


potInstantDxTag :: Text
potInstantDxTag = "potInstantDx"


-----


potHtLiq :: Liq
potHtLiq = Liq (DistinctLiqId iLiqPotHt)
               (DoArticle "pellucid, watery liquid")
               "The smell is similar to that of sea surf upon a beach."
               "The briny taste brings seawater to mind."
               "You do your best to ignore the overpowering saltiness."


potHtDistinctLiq :: DistinctLiq
potHtDistinctLiq = DistinctLiq "pot_HT" EdibleEffects { _digestEffects  = Just de
                                                      , _consumpEffects = Nothing }
  where
    de = EffectList . pure . Right $ e
    e  = Effect { _effectTag     = Nothing
                , _effectSub     = EffectAttrib Ht
                , _effectVal     = Just . EffectFixedVal $ potAttribEffectVal
                , _effectDur     = potAttribEffectDur
                , _effectFeeling = Nothing }


potInstantHtLiq :: Liq
potInstantHtLiq = Liq (DistinctLiqId iLiqPotInstantHt)
                      (DoArticle "dirty liquid")
                      "It smells like an ashtray!"
                      ("It tastes like soot and coal. " <> f "Now your mouth feels dirty and gross")
                      (f "You swallow gritty lumps of" <> " something. Could it be dirt? " <> f "Hmm")
  where
    f = thrice prd


potInstantHtDistinctLiq :: DistinctLiq
potInstantHtDistinctLiq = DistinctLiq "pot_insta_HT" EdibleEffects { _digestEffects  = Nothing
                                                                   , _consumpEffects = Just ce }
  where
    ce = mkPotConsumpEffects es
    es = EffectList . pure . Right $ e
    e  = Effect { _effectTag     = Just potInstantHtTag
                , _effectSub     = EffectAttrib Ht
                , _effectVal     = Just . EffectRangedVal $ potInstantAtttribEffectRange
                , _effectDur     = potAttribEffectDur
                , _effectFeeling = Nothing }


potInstantHtTag :: Text
potInstantHtTag = "potInstantHt"


-----


potMaLiq :: Liq
potMaLiq = Liq (DistinctLiqId iLiqPotMa)
               (DoArticle "creamy, white liquid")
               "The creamy liquid has a faint, sweet odor."
               "The creamy liquid has a consistency reminiscent of coconut juice and a sweet, vaguely fruity taste."
               "The sweet, creamy tonic is delicious."


potMaDistinctLiq :: DistinctLiq
potMaDistinctLiq = DistinctLiq "pot_MA" EdibleEffects { _digestEffects  = Just de
                                                      , _consumpEffects = Nothing }
  where
    de = EffectList . pure . Right $ e
    e  = Effect { _effectTag     = Nothing
                , _effectSub     = EffectAttrib Ma
                , _effectVal     = Just . EffectFixedVal $ potAttribEffectVal
                , _effectDur     = potAttribEffectDur
                , _effectFeeling = Nothing }


potInstantMaLiq :: Liq
potInstantMaLiq = Liq (DistinctLiqId iLiqPotInstantMa)
                      (DoArticle "creamy, indigo liquid")
                      "The frothy liquid smells like dye."
                      "The plant-based concoction is quite bitter, though there is a sugary sweetness as well."
                      "A sharply bitter taste hits you immediately, followed by a cloying sweetness."


potInstantMaDistinctLiq :: DistinctLiq
potInstantMaDistinctLiq = DistinctLiq "pot_insta_MA" EdibleEffects { _digestEffects  = Nothing
                                                                   , _consumpEffects = Just ce }
  where
    ce = mkPotConsumpEffects es
    es = EffectList . pure . Right $ e
    e  = Effect { _effectTag     = Just potInstantMaTag
                , _effectSub     = EffectAttrib Ma
                , _effectVal     = Just . EffectRangedVal $ potInstantAtttribEffectRange
                , _effectDur     = potAttribEffectDur
                , _effectFeeling = Nothing }


potInstantMaTag :: Text
potInstantMaTag = "potInstantMa"


-----


potPsLiq :: Liq
potPsLiq = Liq (DistinctLiqId iLiqPotPs)
               (DoArticle "syrupy, amber liquid")
               "The syrup smells smoky-sweet."
               "The viscous syrup tastes remarkably like brown sugar."
               "You suck and slurp down the thick syrup."


potPsDistinctLiq :: DistinctLiq
potPsDistinctLiq = DistinctLiq "pot_PS" EdibleEffects { _digestEffects  = Just de
                                                      , _consumpEffects = Nothing }
  where
    de = EffectList . pure . Right $ e
    e  = Effect { _effectTag     = Nothing
                , _effectSub     = EffectAttrib Ps
                , _effectVal     = Just . EffectFixedVal $ potAttribEffectVal
                , _effectDur     = potAttribEffectDur
                , _effectFeeling = Nothing }


potInstantPsLiq :: Liq
potInstantPsLiq = Liq (DistinctLiqId iLiqPotInstantPs)
                      (DoArticle "incandescent, sky-blue liquid")
                      "There is a striking scent of mist on a cold morning."
                      "The liquid itself might be tasteless. The smell, however, is pronounced."
                      (thrice prd "The liquid doesn't taste like much" <> " until the smell of cold rain hits you like a thick fog.")


potInstantPsDistinctLiq :: DistinctLiq
potInstantPsDistinctLiq = DistinctLiq "pot_insta_PS" EdibleEffects { _digestEffects  = Nothing
                                                                   , _consumpEffects = Just ce }
  where
    ce = mkPotConsumpEffects es
    es = EffectList . pure . Right $ e
    e  = Effect { _effectTag     = Just potInstantPsTag
                , _effectSub     = EffectAttrib Ps
                , _effectVal     = Just . EffectRangedVal $ potInstantAtttribEffectRange
                , _effectDur     = potAttribEffectDur
                , _effectFeeling = Nothing }


potInstantPsTag :: Text
potInstantPsTag = "potInstantPs"


-----


potTinnitusLiq :: Liq
potTinnitusLiq = Liq (DistinctLiqId iLiqPotTinnitus)
                     (DoArticle "olive-green liquid")
                     "The tonic smells pleasingly sweet."
                     "A vague, leafy-green taste is offset by a palatable sweetness."
                     "The thirst-quenching draft leaves you feeling refreshed."


potTinnitusDistinctLiq :: DistinctLiq
potTinnitusDistinctLiq = DistinctLiq "pot_tinnitus" EdibleEffects { _digestEffects  = Just de
                                                                  , _consumpEffects = Nothing }
  where
    de = EffectList . pure . Left $ ie
    ie = InstaEffect { _instaEffectSub     = InstaEffectOther potTinnitusTag
                     , _instaEffectVal     = Nothing
                     , _instaEffectFeeling = mkPotEffectFeeling potTinnitusTag }


potTinnitusTag :: Text
potTinnitusTag = "potTinnitus"


potInstantTinnitusLiq :: Liq
potInstantTinnitusLiq = Liq (DistinctLiqId iLiqPotInstantTinnitus)
                            (DoArticle "oily, puce liquid")
                            "You are greeted by a spicy, buttery odor."
                            "The oily liquid greases your tongue. Its rich, spicy taste is not particularly appetizing."
                            "The draft coats your mouth and throat with a slippery residue."


potInstantTinnitusDistinctLiq :: DistinctLiq
potInstantTinnitusDistinctLiq = DistinctLiq "pot_insta_tinnitus" EdibleEffects { _digestEffects  = Nothing
                                                                               , _consumpEffects = Just ce }
  where
    ce = mkPotConsumpEffects es
    es = EffectList . pure . Right $ e
    e  = Effect { _effectTag     = Just potTinnitusTag
                , _effectSub     = EffectOther potTinnitusTag
                , _effectVal     = Nothing
                , _effectDur     = twoMinsInSecs
                , _effectFeeling = Just . EffectFeeling potTinnitusTag $ twoMinsInSecs }
