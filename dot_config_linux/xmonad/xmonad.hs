import XMonad
import XMonad.Layout.Gaps
import XMonad.Layout.Spacing
import XMonad.Layout.NoBorders
import XMonad.Hooks.SetWMName
import XMonad.Util.EZConfig

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Hooks.ManageHelpers

import XMonad.Util.Loggers

import qualified XMonad.Util.Hacks as Hacks


myXmobarPP :: PP
myXmobarPP = def
    { ppSep = magenta " • "
    , ppTitleSanitize = xmobarStrip
    , ppCurrent = wrap " " "" . xmobarBorder "Top" "#8be9fd" 2
    , ppHidden  = white . wrap " " ""
--    , ppHiddenNoWindows = lowWhite . wrap " " ""
    , ppUrgent = red . wrap (yellow "!") (yellow "!")
--    , ppOrder = \[ws, l, _, wins] -> [ws, l, wins]
--    , ppExtras = [logTitles formatFocused formatUnfocused]
    }
    where
        formatFocused   = wrap (white    "[") (white    "]") . magenta . ppWindow
        formatUnfocused = wrap (lowWhite "[") (lowWhite "]") . blue    . ppWindow

        ppWindow :: String -> String
        ppWindow = xmobarRaw . (\w -> if null w then "untitled" else w) . shorten 30

        magenta = xmobarColor "#ff79c6" ""
        blue = xmobarColor "#bd93f9" ""
        white = xmobarColor "#f8f8f2" ""
        yellow = xmobarColor "#f1fa8c" ""
        red = xmobarColor "#ff5555" ""
        lowWhite = xmobarColor "#bbbbbb" ""

myManageHook :: ManageHook
myManageHook = composeAll
    [ className =? "Gimp" --> doFloat
    , isDialog            --> doFloat
    ]

main :: IO ()
main = xmonad 
    $ withEasySB (statusBarProp "xmobar" (pure myXmobarPP)) defToggleStrutsKey 
    $ myConfig
    where
        toggleStrutsKey :: XConfig Layout -> (KeyMask, KeySym)
        toggleStrutsKey XConfig{ modMask = m } = (m, xK_b)

myLayoutHook = Tall 1 (3/100) (1/2) ||| noBorders Full

myConfig = def
    { terminal = "kitty"
    , focusFollowsMouse = False -- disable mouse auto focus
    -- , layoutHook = gaps [(U,72), (R,24)] $ Tall 1 (3/100) (1/2) ||| Full
    , startupHook = setWMName "LG3D"
    , layoutHook = spacingWithEdge 10 
    -- $ gaps [(U, 36)] 
    $ myLayoutHook
    -- fix chromium based app full screen bizzard behavior
    , handleEventHook = handleEventHook def <> Hacks.windowedFullscreenFixEventHook
    }
    `removeKeysP`
    [ ("M-<Space>")
    , ("M-<Return>")
    , ("M-p")
    ]
    `additionalKeysP`
    [ ("M-<Space>", spawn "rofi -show")
    , ("M-n", sendMessage NextLayout)
    -- , ("M-space", spawn "rofi -show")
    ]

