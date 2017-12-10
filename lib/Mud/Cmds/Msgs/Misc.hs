{-# LANGUAGE OverloadedStrings #-}

module Mud.Cmds.Msgs.Misc where

import           Mud.Data.State.MudData
import           Mud.TopLvlDefs.Chars
import           Mud.TopLvlDefs.Misc
import           Mud.Util.Misc
import           Mud.Util.Operators
import           Mud.Util.Quoting
import           Mud.Util.Text

import           Data.Monoid ((<>))
import           Data.Text (Text)
import qualified Data.Text as T

lSpcs :: Text
lSpcs = T.replicate 2 . T.pack $ miscTokenDelimiter : "l"

-----

adminKillMsg :: Text -> Text
adminKillMsg t = "There is a blinding yellow light and a deafening crack as " <> t <> " instantly struck dead!"

asMsg :: Text
asMsg = "You suddenly feel as though someone else is in control..."

bannedMsg :: Text
bannedMsg = "You have been banned from CurryMUD!"

blankWritableMsg :: Sing -> Text
blankWritableMsg s = prd $ "There isn't anything written on the " <> s

bookFileErrorMsg :: Text -> Text
bookFileErrorMsg n = "Unfortunately, the " <> n <> " book file could not be read."

bookListErrorMsg :: Text
bookListErrorMsg = "Unfortunately, the book list could not be retrieved."

corpseSmellLvl1Msg, corpseSmellLvl2Msg, corpseSmellLvl3Msg, corpseSmellLvl4Msg :: Text
corpseSmellLvl1Msg = "Due to the lack of an offensive odor, it's clear that the deceased expired recently."
corpseSmellLvl2Msg = "There is an unpleasant scent akin to that of rotting fruit."
corpseSmellLvl3Msg = "The multifaceted odor is truly putrid."
corpseSmellLvl4Msg = ((<>) <$> ("Oh my" |&|) <*> (" so rank, so sickeningly sweet" |&|)) (thrice prd)

darkMsg :: Text
darkMsg = "It's too dark to make out much at all."

dbEmptyMsg :: Text
dbEmptyMsg = "The database is empty."

dbErrorMsg :: Text
dbErrorMsg = "There was an error while reading the database."

descRulesMsg :: Text
descRulesMsg =
    "1) Descriptions must be realistic and reasonable. A felinoid with an unusual fur color is acceptable, while a \
    \six-foot dwarf is not.3`\n\
    \2) Descriptions must be passive and written from an objective viewpoint. \"He is exceptionally thin\" is \
    \acceptable, while \"You can't believe how thin he is\" is not.3`\n\
    \3) Descriptions may only contain observable information. \"People tend to ask her about her adventures\" and \"He \
    \is a true visionary among elves\" are both illegal. Likewise, you may not include your character's name in your \
    \description.3`\n\
    \4) Keep your description short. The longer your description, the less likely people are to actually read it!3`"

descRule5 :: Text
descRule5 =
    "5) You may not make radical changes to your description without a plausible in-game explanation. This means that \
    \it is normally illegal to make sudden, striking changes to enduring physical characteristics (height, eye color, \
    \etc.). If you would like to make such a change and feel there could be a plausible in-game explanation, get \
    \permission from an administrator first.3`"

dfltBootMsg :: Text
dfltBootMsg = "You have been booted from CurryMUD. Goodbye!"

dfltShutdownMsg :: Text
dfltShutdownMsg = "CurryMUD is shutting down. We apologize for the inconvenience. See you soon!"

effortsBlockedMsg :: Text
effortsBlockedMsg = "Your efforts are blocked; "

egressMsg :: Text -> Text
egressMsg n = n <> " slowly dissolves into nothingness."

enterDescMsg :: Text
enterDescMsg = T.unlines . map (lSpcs <>) $ ts
  where
    ts = [ "Enter your new description below. You may write multiple lines of text; however, multiple lines will be \
           \joined into a single line which, when displayed, will be wrapped according to one's columns setting."
         , "You are encouraged to compose your description in an external text editor (such as TextEdit on Mac, and \
           \gedit or kate on Linux systems) with spell checking enabled. Copy your completed description from there and \
           \paste it into your MUD client."
         , "When you are finished, enter a " <> endCharTxt <> " on a new line." ]
    endCharTxt = dblQuote . T.singleton $ multiLineEndChar

exhaustedMsg :: Text
exhaustedMsg = "You are too exhausted to move."

focusingInnateMsg :: Text
focusingInnateMsg = "Focusing your innate psionic energy for a brief moment, "

genericErrorMsg :: Text
genericErrorMsg = "Unfortunately, an error occurred while executing your command."

helloRulesMsg :: Text
helloRulesMsg = asteriskQuote "By logging in you are expressing a commitment to follow the rules."

helpRootErrorMsg :: Text
helpRootErrorMsg = helpFileErrorMsg "root"

helpFileErrorMsg :: Text -> Text
helpFileErrorMsg n = "Unfortunately, the " <> n <> " help file could not be read."

humMsg :: Text -> Text
humMsg t = prd $ "A faint, steady hum is originating from the " <> t

inacBootMsg :: Text
inacBootMsg = "You are being disconnected from CurryMUD due to inactivity."

leftChanMsg :: Text -> ChanName -> Text
leftChanMsg n cn = T.concat [ "You sense that ", n, " has left the ", dblQuote cn, " channel." ]

linkLostMsg :: Sing -> Text
linkLostMsg s = "Your telepathic link with " <> s <> " fizzles away!"

linkMissingMsg :: Sing -> Text
linkMissingMsg s = "You notice that your telepathic link with " <> s <> " is missing..."

linkRetainedMsg :: Sing -> Text
linkRetainedMsg s = "There is a sudden surge of energy over your telepathic link with " <> s <> "!"

loadTblErrorMsg :: FilePath -> Text -> Text
loadTblErrorMsg fp msg = T.concat [ "error parsing ", dblQuote . T.pack $ fp, ": ", msg, "." ]

loadWorldErrorMsg :: Text
loadWorldErrorMsg = "There was an error loading the world. Check the error log for details."

lvlUpMsg :: Text
lvlUpMsg = "Congratulations! You gained a level."

motdErrorMsg :: Text
motdErrorMsg = "Unfortunately, the message of the day could not be retrieved."

msgRetainedMsg :: Text
msgRetainedMsg = "(Message retained.)"

newPlaMsg :: Text
newPlaMsg =
    lSpcs <> "Welcome, and thank you for trying CurryMUD!\n" <>
    lSpcs <> "Before you can enter the game, you must first create a character: your new identity in the fantasy virtual world. The first step is to invent a name for your character.\n" <>
    lSpcs <> "You must choose an original fantasy name. The following are unallowed:\n\
    \* Real-world English proper names. (Please also try to avoid proper names from Japanese and other languages.)2`\n\
    \* Well-known names from popular books, movies, and games.2`\n\
    \* Established names in mythology and folklore.2`\n\
    \* Words from the English dictionary.2`\n" <>
    lSpcs <> "If you have trouble coming up with a name, consider using one of the many fantasy name generators available on the web."

noSmellMsg :: Text
noSmellMsg = "You don't smell anything in particular."

noSoundMsg :: Text
noSoundMsg = "You don't hear anything in particular."

noTasteMsg :: Text
noTasteMsg = "You don't taste anything in particular."

notifyArrivalMsg :: Text -> Text
notifyArrivalMsg n = n <> " slowly materializes out of thin air."

plusRelatedMsg :: Text
plusRelatedMsg = "(plus related functionality)."

pwMsg :: Text -> [Text]
pwMsg t =
    [ T.concat [ t, " Passwords must be ", showTxt minPwLen, "-", showTxt maxPwLen, " characters in length and contain:" ]
    , "* 1 or more lowercase characters"
    , "* 1 or more uppercase characters"
    , "* 1 or more digits"
    , "* 0 whitespace characters" ]

pwWarningMsg :: Text -- Do not indent with leading spaces.
pwWarningMsg = "Please make a note of your new password. If you lose your password, you may lose your character!"

rethrowExMsg :: Text -> Text
rethrowExMsg t = "exception caught " <> t <> "; rethrowing to listen thread"

rulesIntroMsg :: Text
rulesIntroMsg = "In order to preserve the integrity of the virtual world along with the enjoyment of all, the \
                \following rules must be observed."

rulesMsg :: Text
rulesMsg =
    "\\h RULES \\d\n\
    \\n" <>
    lSpcs <> "You must conduct yourself in accordance with the following rules. It is not the case that you are allowed to do whatever the virtual world lets you do: please understand this important point.\n" <>
    lSpcs <> T.cons miscTokenDelimiter "v\n\
    \\n\
    \\\uAGE\\d\n" <>
    lSpcs <> "CurryMUD is a complex game that requires serious, consistent role-play and adult sensibilities. For these reasons you must be at least 18 years old to play.\n\
    \\n\
    \\\uROLE-PLAY\\d\n" <>
    lSpcs <> "CurryMUD is a Role-Play Intensive (RPI) MUD. You are required to devise a unique personality for your character and to stay In Character (IC) at all times. IC communication must always stay within the fantasy context of the virtual world; references to the present day/reality are not allowed.\n" <>
    lSpcs <> "There are a few exceptions to this rule. The \"question channel\" (for asking and answering newbie questions related to game play) is Out-Of-Character (OOC). Certain areas within the virtual world are also clearly designated as OOC: you are allowed to communicate with other players as a player (as yourself) within such areas.\n\
    \\n\
    \\\uILLEGAL ROLE-PLAY\\d\n" <>
    lSpcs <> "You are not allowed to role-play a character who is insane, sadistic, or sociopathic.\n\
    \\n\
    \\\uSEXUAL ORIENTATION/IDENTITY\\d\n" <>
    lSpcs <> "Players are free to role-play characters who are homosexual, bisexual, pansexual, gender nonconforming, etc. Intolerant attitudes are unacceptable.\n\
    \\n\
    \\\uHARASSMENT\\d\n" <>
    lSpcs <> "Harassment and bullying is not tolerated. The role-play of rape is absolutely illegal.\n\
    \\n\
    \\\uPLAYER-VS-PLAYER\\d\n" <>
    lSpcs <> "In Character (IC) conflict between Player Characters (PCs) may occur. Administrators will generally not step in to resolve such conflict.\n" <>
    lSpcs <> "PC-on-PC combat is not the focus of CurryMUD and should not be a common occurrence. You may not attack other PCs indiscriminately. Your PC may attack another PC if and only if there is a viable IC reason to justify the attack, such as, \"he stole my stuff,\" or, \"she betrayed me.\" \"My PC hates vulpenoids and he was a vulpenoid\" is not in and of itself an acceptable justification for the murder of a PC.\n\
    \\n\
    \\\uPERMADEATH\\d\n" <>
    lSpcs <> "When a Player Character (PC) dies, he/she is truly dead; a deceased character cannot return to the virtual world in any way, shape, or form. This is known as \"permadeath.\" By playing CurryMUD, you consent to the fact that when your character dies, he/she is unrecoverable.\n\
    \\n\
    \\\uMULTI-PLAYING\\d\n" <>
    lSpcs <> "\"Multi-playing\" is when a single player simultaneously logs in multiple times, as multiple characters. This is not allowed.\n" <>
    lSpcs <> "It is likewise illegal to transfer items and wealth between characters through indirect means (for example, dropping items in a certain location, logging in as a different character, and picking up those items).\n" <>
    lSpcs <> "You are discouraged from actively maintaining multiple characters at a time. It can be quite difficult to juggle the different scopes of knowledge - and to maintain the disparate levels of objectivity - inherent in multiple characters. If you find yourself wanting to play a new character, consider formally retiring your current character.\n\
    \\n\
    \\\uBUGS\\d\n" <>
    lSpcs <> "The abuse of bugs constitutes cheating and is not allowed. If you find a bug, you must promptly report it via the \"bug\" command, or inform an administrator directly via the \"admin\" command.\n\
    \\n\
    \\\uPRIVACY\\d\n" <>
    lSpcs <> "Please be aware that player activity is automatically logged by the system. Furthermore, administrators have the ability to actively monitor player activity with the express purpose of 1) ensuring that players are following the rules, and 2) tracking down bugs. Administrators promise to maintain player privacy as much as possible."

sleepMsg :: Text
sleepMsg = "You go to sleep..."

smellCoinMsg :: Text -> Bool -> Text
smellCoinMsg t isPlur = T.concat [ "The ", t, " smell", not isPlur |?| "s", " of metal, with just a hint of grime." ]

spiritDetachMsg :: Text
spiritDetachMsg = "Your spirit detaches from your dead body!"

sudoMsg :: Text
sudoMsg = "HELLO, ROOT! We trust you have received the usual lecture from the local System Administrator..."

tasteCoinMsg :: Text -> Text
tasteCoinMsg t = "You are first struck by an unmistakably metallic taste, followed soon by the salty essence of sweat \
                 \and waxy residue from the hands of the many people who handled the " <> t <> " before you."

teleDescMsg :: Text
teleDescMsg = "You are instantly transported in a blinding flash of white light. For a brief moment you are \
              \overwhelmed with vertigo accompanied by a confusing sensation of nostalgia."

teleDestMsg :: Text -> Text
teleDestMsg t = "There is a soft audible pop as " <> t <> " appears in a jarring flash of white light."

teleOriginMsg :: Text -> Text
teleOriginMsg t = "There is a soft audible pop as " <> t <> " vanishes in a jarring flash of white light."

theBeyondMsg :: Text
theBeyondMsg = "Your spirit passes into the beyond. A hand reaches out to guide you, and pulls you in..."

unlinkMsg :: Text -> Sing -> Text
unlinkMsg t s = T.concat [ "You suddenly feel a slight tingle ", t, "; you sense that your telepathic link with ", s
                         , " has been severed." ]

violationMsg :: Text
violationMsg = "Violation of these rules is grounds for discipline up to and including banishment from CurryMUD."
