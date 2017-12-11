{-# LANGUAGE OverloadedStrings, ViewPatterns #-}

module Mud.Interp.Misc ( mkChoiceTxt
                       , mkYesNoChoiceTxt
                       , neverMind
                       , promptChangeIt
                       , promptRetryYesNo
                       , resetInterp
                       , yesNoHelper ) where

import qualified Data.Text as T
import           Mud.Data.Misc
import           Mud.Data.State.MsgQueue
import           Mud.Data.State.MudData
import           Mud.Data.State.Util.Misc
import           Mud.Data.State.Util.Output
import           Mud.Misc.ANSI
import           Mud.Util.Misc
import           Mud.Util.Operators
import           Mud.Util.Quoting
import           Mud.Util.Text

import           Control.Lens.Operators ((.~))
import           Control.Monad (guard)
import           Data.Monoid ((<>))
import           Data.Text (Text)

mkChoiceTxt :: [Text] -> Text
mkChoiceTxt = bracketQuote . T.intercalate "/" . colorize
  where
    colorize []                                               = []
    colorize ((T.uncons -> Just (T.singleton -> x, rest)):xs) = (colorWith abbrevColor x <> rest) : colorize xs
    colorize (_:xs)                                           = colorize xs

mkYesNoChoiceTxt :: Text
mkYesNoChoiceTxt = mkChoiceTxt [ "yes", "no" ]

-----

neverMind :: Id -> MsgQueue -> MudStack ()
neverMind i mq = send mq (nlnl "Never mind.") >> sendDfltPrompt mq i >> resetInterp i

-----

promptChangeIt :: MsgQueue -> Cols -> MudStack ()
promptChangeIt mq cols = wrapSendPrompt mq cols $ "Would you like to change it? " <> mkYesNoChoiceTxt

-----

promptRetryYesNo :: MsgQueue -> Cols -> MudStack ()
promptRetryYesNo mq cols = wrapSendPrompt mq cols "Please answer \"yes\" or \"no\"."

-----

resetInterp :: Id -> MudStack ()
resetInterp i = tweak (mobTbl.ind i.interp .~ Nothing)

-----

yesNoHelper :: Text -> Maybe Bool
yesNoHelper (T.toLower -> a) = guard (()!# a) >> helper
  where
    helper | a `T.isPrefixOf` "yes" = return True
           | a `T.isPrefixOf` "no"  = return False
           | otherwise              = Nothing
