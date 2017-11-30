{-# OPTIONS_GHC -Wno-type-defaults #-}
{-# LANGUAGE OverloadedStrings #-}

module Mud.Data.State.Util.GMCP ( gmcpRmInfo
                                , gmcpVitals ) where

import           Mud.Data.State.MudData
import           Mud.Data.State.Util.Get
import           Mud.Data.State.Util.Misc
import           Mud.TheWorld.Zones.ZoneMap
import qualified Mud.Util.Misc as U (blowUp)
import           Mud.Util.Misc hiding (blowUp)
import           Mud.Util.Quoting
import           Mud.Util.Text

import           Control.Lens (both, each, views)
import           Control.Lens.Operators ((&), (%~), (^.))
import           Data.List (lookup)
import           Data.Maybe (fromMaybe)
import           Data.Monoid ((<>))
import           Data.Text (Text)
import qualified Data.Text as T


default (Int)


-----


blowUp :: BlowUp a
blowUp = U.blowUp "Mud.Data.State.Util.GMCP"


-- ==================================================


colon, comma :: Text
colon = ": "
comma = ", "


-----


gmcpRmInfo :: Maybe Int -> Id -> MudState -> Text
gmcpRmInfo maybeZoom i ms = "Room.Info " <> curlyQuote (spaced rest)
  where
    rest = T.concat [ dblQuote "area_name"    <> colon
                    , dblQuote zoneName       <> comma
                    , dblQuote "room_id"      <> colon
                    , showTxt ri              <> comma
                    , dblQuote "room_name"    <> colon
                    , dblQuote roomName       <> comma
                    , dblQuote "x_coord"      <> colon
                    , showTxt xCoord          <> comma
                    , dblQuote "y_coord"      <> colon
                    , showTxt yCoord          <> comma
                    , dblQuote "z_coord"      <> colon
                    , showTxt zCoord          <> comma
                    , dblQuote "room_env"     <> colon
                    , env                     <> comma
                    , dblQuote "room_label"   <> colon
                    , label                   <> comma
                    , dblQuote "room_exits"   <> colon
                    , mkExits                 <> comma
                    , dblQuote "last_room_id" <> colon
                    , showTxt lastId          <> comma
                    , mkDir                   <> comma
                    , dblQuote "zoom"         <> colon
                    , showTxt zoom ]
    ri                       = getRmId i ms
    zoneName                 = getZoneForRmId ri
    rm                       = getRm ri ms
    roomName                 = rm^.rmName
    (xCoord, yCoord, zCoord) = rm^.rmCoords
    env                      = views rmEnv   (showTxt  . envToColorInt) rm
    label                    = views rmLabel (dblQuote . fromMaybeEmp ) rm
    mkExits                  = views rmLinks exitHelper rm
      where
        exitHelper links =
            let f (StdLink dir _ _ ) = pure . dirToInt . linkDirToCmdName $ dir
                f _                  = []
            in bracketQuote . spaced . commas . map showTxt . concatMap f $ links
    dirToInt t = fromMaybe oops . lookup t $ dirs
      where
        dirs = zip [ "n", "ne", "nw", "e", "w", "s", "se", "sw", "u", "d", "in", "out" ] [1..]
        oops = blowUp "gmcpRmInfo dirToInt" "nonstandard direction" t
    lastId = getLastRmId i ms
    mkDir  = views rmLinks dirHelper . getRm lastId $ ms
      where
        dirHelper links =
            let f (StdLink    dir destId _    ) | destId == ri = mkStdDir . linkDirToCmdName $ dir
                f (NonStdLink n   destId _ _ _) | destId == ri =
                    case n of "u"   -> g
                              "d"   -> g
                              "in"  -> g
                              "out" -> g
                              _     -> pure . T.concat $ [ dblQuote "dir",         colon, "-1", comma
                                                         , dblQuote "special_dir", colon, dblQuote n ]
                  where
                    g = mkStdDir n
                f _ = []
                mkStdDir t = pure . T.concat $ [ dblQuote "dir",         colon, showTxt . dirToInt $ t, comma
                                               , dblQuote "special_dir", colon, dblQuote "-1" ]
            in case concatMap f links of (x:_) -> x
                                         []    -> T.concat [ dblQuote "dir",         colon, "-1", comma
                                                           , dblQuote "special_dir", colon, dblQuote "-1" ]
    zoom = fromMaybe (-1) maybeZoom


-- Numbers correspond to Mudlet's user-adjustable mapper colors.
envToColorInt :: RmEnv -> Int
envToColorInt InsideUnlitEnv = 262 -- Cyan.
envToColorInt InsideLitEnv   = 262 -- Cyan.
envToColorInt OutsideEnv     = 266 -- Light green.
envToColorInt ShopEnv        = 265 -- Light red.
envToColorInt SpecialEnv     = 269 -- Light magenta.
envToColorInt NoEnv          = 264 -- Light black.


-----


gmcpVitals :: Id -> MudState -> Text
gmcpVitals i ms = "Char.Vitals " <> curlyQuote (spaced rest)
  where
    rest = T.concat [ dblQuote "curr_hp" <> colon
                    , hpCurr             <> comma
                    , dblQuote "max_hp"  <> colon
                    , hpMax              <> comma
                    ----------
                    , dblQuote "curr_mp" <> colon
                    , mpCurr             <> comma
                    , dblQuote "max_mp"  <> colon
                    , mpMax              <> comma
                    ----------
                    , dblQuote "curr_pp" <> colon
                    , ppCurr             <> comma
                    , dblQuote "max_pp"  <> colon
                    , ppMax              <> comma
                    ----------
                    , dblQuote "curr_fp" <> colon
                    , fpCurr             <> comma
                    , dblQuote "max_fp"  <> colon
                    , fpMax ]
    ((hpCurr, hpMax), (mpCurr, mpMax), (ppCurr, ppMax), (fpCurr, fpMax)) = f
    f = getPts i ms & each %~ (both %~ showTxt)
