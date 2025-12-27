import Control.Monad (join, when)
import qualified Data.Map as M
import Data.Maybe (maybeToList)
import Data.Monoid (Endo (..))
import Graphics.X11.ExtraTypes.XF86 (xF86XK_AudioLowerVolume, xF86XK_AudioMute, xF86XK_AudioNext, xF86XK_AudioPlay, xF86XK_AudioPrev, xF86XK_AudioRaiseVolume, xF86XK_MonBrightnessDown, xF86XK_MonBrightnessUp)
import System.Exit ()
import XMonad
import XMonad.Actions.CycleWS
import XMonad.Actions.WithAll (sinkAll)
import XMonad.Hooks.EwmhDesktops (ewmh)
import XMonad.Hooks.ManageDocks
  ( Direction2D (D, L, R, U),
    avoidStruts,
    docks,
    manageDocks,
  )
import XMonad.Hooks.ManageHelpers (doFullFloat, isFullscreen)
import XMonad.Layout.Fullscreen
  ( fullscreenEventHook,
    fullscreenFull,
    fullscreenManageHook,
    fullscreenSupport,
  )
import XMonad.Layout.Gaps
  ( Direction2D (D, L, R, U),
    GapMessage (DecGap, IncGap, ToggleGaps),
    gaps,
    setGaps,
  )
import XMonad.Layout.NoBorders
import XMonad.Layout.Spacing (Border (Border), spacingRaw)
import qualified XMonad.StackSet as W
import XMonad.Util.Paste
import XMonad.Util.SpawnOnce (spawnOnce)

toggleFull :: X ()
toggleFull = withFocused $ \w -> windows =<< appEndo `fmap` runQuery doFullFloat w

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal = "ghostty"

-- myTerminal      = "xfce4-terminal"
-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth = 2

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask = mod4Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
wsTerm = "\62601"

wsBrow = "\62057"

wsFile = "\61563"

wsGame = "\61723"

wsText = "\57879"

wsVirt = "\61704"

wsGit = "\62102"

wsArch = "\62211"

wsMusic = "\61441"

myWorkspaces = [wsTerm, wsBrow, wsFile, wsGame, wsText, wsVirt, wsGit, wsArch, wsMusic]

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor = "#3b4252"

myFocusedBorderColor = "#bc96da"

addNETSupported :: Atom -> X ()
addNETSupported x = withDisplay $ \dpy -> do
  r <- asks theRoot
  a_NET_SUPPORTED <- getAtom "_NET_SUPPORTED"
  a <- getAtom "ATOM"
  liftIO $ do
    sup <- (join . maybeToList) <$> getWindowProperty32 dpy a_NET_SUPPORTED r
    when (fromIntegral x `notElem` sup) $
      changeProperty32 dpy r a_NET_SUPPORTED a propModeAppend [fromIntegral x]

addEWMHFullscreen :: X ()
addEWMHFullscreen = do
  wms <- getAtom "_NET_WM_STATE"
  wfs <- getAtom "_NET_WM_STATE_FULLSCREEN"
  mapM_ addNETSupported [wms, wfs]

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
clipboardy :: (MonadIO m) => m () -- Don't question it
clipboardy = spawn "cliphist list | ~/.config/rofi/launchers/type-2/clipboardLauncher.sh | cliphist decode | wl-copy"

maimcopy = spawn "maim -s | xclip -selection clipboard -t image/png && notify-send \"Screenshot\" \"Copied to Clipboard\" -i flameshot"

maimsave = spawn "maim -s ~/Desktop/$(date +%Y-%m-%d_%H-%M-%S).png && notify-send \"Screenshot\" \"Saved to Desktop\" -i flameshot"

rofi_launcher = "~/.config/rofi/launchers/type-2/launcher.sh"

window_tasks = "~/.config/rofi/launchers/type-2/windowsLauncher.sh"

rofi_emoji = spawn "rofi -show emoji -emoji-format '{emoji}' -modi emoji -theme '~/.config/rofi/emoji/style-8.rasi'"

myKeys conf@(XConfig {XMonad.modMask = modm}) =
  M.fromList $
    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf),
      -- lock screen
      ((modm .|. controlMask, xK_l), spawn "betterlockscreen -l"),
      ((modm, xK_f), toggleFull),
      -- launch rofi and dashboard
      ((modm, xK_o), spawn rofi_launcher),
      ((modm, xK_v), spawn "pwvucontrol"),
      -- Audio keys
      ((0, xF86XK_AudioPlay), spawn "playerctl play-pause"),
      ((0, xF86XK_AudioPrev), spawn "playerctl previous"),
      ((0, xF86XK_AudioNext), spawn "playerctl next"),
      ((0, xF86XK_AudioRaiseVolume), spawn "pactl set-sink-volume 0 +5%"),
      ((0, xF86XK_AudioLowerVolume), spawn "pactl set-sink-volume 0 -5%"),
      ((shiftMask, xF86XK_AudioRaiseVolume), spawn "pactl set-sink-volume bluez_sink.0C_5A_E0_A0_80_5D.a2dp_sink +5%"),
      ((shiftMask, xF86XK_AudioLowerVolume), spawn "pactl set-sink-volume bluez_sink.0C_5A_E0_A0_80_5D.a2dp_sink -5%"),
      ((0, xF86XK_AudioMute), spawn "pactl set-sink-mute 0 toggle"),
      -- Brightness keys
      ((0, xF86XK_MonBrightnessUp), spawn "brightnessctl s +10%"),
      ((0, xF86XK_MonBrightnessDown), spawn "brightnessctl s 10-%"),
      -- Screenshot
      ((0, xK_Print), maimcopy),
      ((modm, xK_Print), maimsave),
      -- My Stuff
      ((modm, xK_b), spawn "export XDG_CURRENT_DESKTOP='XMonad'; ~/bin/toggle_bar.sh"),
      ((modm .|. mod1Mask, xK_period), rofi_emoji),
      ((modm, xK_z), spawn "exec ~/bin/inhibit_activate"),
      ((modm .|. shiftMask, xK_z), spawn "exec ~/bin/inhibit_deactivate"),
      -- , ((modm,               xK_p     ), spawn "caffeine kill && caffeine start -a")
      -- , ((modm .|. shiftMask, xK_p     ), spawn "caffeine kill && caffeine")
      ((modm .|. shiftMask, xK_a), spawn "clipcat-menu"),
      ((modm, xK_a), spawn window_tasks),
      -- , ((controlMask .|. shiftMask, xK_b     ), spawn "firefox")
      ((modm .|. shiftMask, xK_b), spawn "zen-browser"),
      ((modm .|. controlMask, xK_b), spawn "brave"),
      ((modm .|. shiftMask, xK_d), spawn "ani-cli -q 480 --rofi --vlc"),
      ((modm .|. mod1Mask, xK_d), spawn "ani-cli -q 480 --rofi --dub --vlc"),
      ((modm .|. shiftMask, xK_s), spawn "redshift -l manual"),
      ((modm, xK_s), spawn "redshift -O 5500"),
      ((modm .|. shiftMask, xK_f), spawn "nemo"),
      -- , ((modm .|. shiftMask, xK_m     ), spawn pak)
      ((modm .|. shiftMask, xK_m), spawn "tauon"),
      ((modm .|. mod1Mask, xK_t), spawn "telegram-desktop"),
      ((modm .|. mod1Mask, xK_m), spawn "LD_PRELOAD=/usr/lib/spotify-adblock.so spotify --uri=%U"),
      ((modm .|. shiftMask, xK_v), spawn "code"),
      ((modm .|. shiftMask, xK_l), spawn "lutris"),
      ((modm .|. mod1Mask, xK_p), spawn "protonvpn"),
      ((controlMask .|. mod1Mask, xK_Right), nextWS),
      ((controlMask .|. mod1Mask, xK_Left), prevWS),
      ((modm, xK_Return), spawn myTerminal),
      -- close focused window
      ((modm, xK_c), kill),
      -- GAPS!!!
      ((modm .|. controlMask, xK_g), sendMessage $ ToggleGaps), -- toggle all gaps
      ((modm .|. shiftMask, xK_g), sendMessage $ setGaps [(L, 10), (R, 10), (U, 60), (D, 20)]), -- reset the GapSpec

      -- Rotate through the available layout algorithms
      ((modm, xK_space), sendMessage NextLayout),
      --  Reset the layouts on the current workspace to default
      ((modm .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf),
      -- Resize viewed windows to the correct size
      ((modm, xK_n), refresh),
      -- Move focus to the next window
      ((modm, xK_Left), windows W.focusDown),
      -- Move focus to the previous window
      ((modm, xK_Right), windows W.focusUp),
      -- Move focus to the master window
      ((modm, xK_m), windows W.focusMaster),
      -- Swap the focused window and the master window
      ((modm, xK_Tab), windows W.swapMaster),
      -- Swap the focused window and the master window
      ((modm, xK_k), windows W.swapMaster),
      -- Swap the focused window with the next window
      ((modm .|. shiftMask, xK_j), windows W.swapDown),
      -- Swap the focused window with the previous window
      ((modm .|. shiftMask, xK_k), windows W.swapUp),
      -- Shrink the master area
      ((modm .|. shiftMask, xK_Left), sendMessage Shrink),
      -- Expand the master area
      ((modm .|. shiftMask, xK_Right), sendMessage Expand),
      -- Push window back into tiling
      ((modm, xK_t), withFocused $ windows . W.sink),
      -- Increment the number of windows in the master area
      ((modm, xK_comma), sendMessage (IncMasterN 1)),
      -- Deincrement the number of windows in the master area
      ((modm, xK_period), sendMessage (IncMasterN (-1))),
      -- Toggle the status bar gap
      -- Use this binding with avoidStruts from Hooks.ManageDocks.
      -- See also the statusBar function from Hooks.DynamicLoC
      --
      -- , ((modm              , xK_b     ), sendMessage ToggleStruts)

      -- Quit xmonad
      ((modm .|. shiftMask, xK_r), spawn "xmonad --recompile; xmonad --restart"),
      -- Restart xmonad
      ((modm, xK_q), spawn "archlinux-logout"),
      -- Run xmessage with a summary of the default keybindings (useful for beginners)
      ((modm .|. shiftMask, xK_slash), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    ]
      ++
      --
      -- mod-[1..9], Switch to workspace N
      -- mod-shift-[1..9], Move client to workspace N
      --
      [ ((m .|. modm, k), windows $ f i)
      | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9],
        (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
      ]
      ++
      --
      -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
      -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
      --
      [ ((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
      | (key, sc) <- zip [xK_w, xK_e, xK_r] [0 ..],
        (f, m) <- [(W.view, 0), (W.shift, shiftMask)]
      ]

------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) =
  M.fromList $
    -- mod-button1, Set the window to floating mode and move by dragging
    [ ( (modm, button1),
        ( \w ->
            focus w
              >> mouseMoveWindow w
              >> windows W.shiftMaster
        )
      ),
      -- mod-button2, Raise the window to the top of the stack
      ((modm, button2), (\w -> focus w >> windows W.shiftMaster)),
      -- mod-button3, Set the window to floating mode and resize by dragging
      ( (modm, button3),
        ( \w ->
            focus w
              >> mouseResizeWindow w
              >> windows W.shiftMaster
        )
      )
      -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
-- myLayout = avoidStruts(tiled ||| Mirror tiled ||| Full)
myLayout = avoidStruts (tiled ||| Full)
  where
    -- default tiling algorithm partitions the screen into two panes
    tiled = Tall nmaster delta ratio

    -- The default number of windows in the master pane
    nmaster = 1

    -- Default proportion of screen occupied by master pane
    ratio = 1 / 2

    -- Percent of screen to increment by when resizing panes
    delta = 3 / 100

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook =
  fullscreenManageHook
    <+> manageDocks
    <+> composeAll
      [ -- Floats
        className =? "MPlayer" --> doFloat,
        className =? "Gimp" --> doFloat,
        className =? "Megasync" --> doFloat,
        className =? "Protonvpn" --> doFloat,
        -- Shifts
        className =? "tauonmb" --> doShift wsMusic,
        className =? "Spotify" --> doShift wsMusic,
        className =? "pwvucontrol" --> doShift wsMusic,
        className =? "Lutris" --> doShift wsGame,
        className =? "Code" --> doShift wsGit,
        className =? "Protonvpn" --> doShift wsArch,
        className =? "Brave-browser" --> doShift wsBrow,
        className =? "zen" --> doShift wsBrow,
        className =? "TelegramDesktop" --> doShift wsText,
        className =? "Virt-manager" --> doShift wsVirt,
        className =? "Vlc" --> doShift wsArch,
        -- FullFloats
        -- , className =? "Brave-browser"           --> doFullFloat
        -- , isFullscreen --> doFullFloat
        resource =? "kdesktop" --> doIgnore,
        resource =? "desktop_window" --> doIgnore
        -- , className =? "com.github.taiko2k.tauonmb"           --> doShift wsMusic
        -- , className =? "com.github.neithern.g4music"           --> doShift wsMusic
      ]

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook

--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = mempty

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
myLogHook = return ()

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = do
  spawnOnce "export XDG_CURRENT_DESKTOP='XMonad'; ~/bin/toggle_bar.sh"
  spawnOnce "exec /usr/lib/pam_kwallet_init"
  spawn "xsetroot -cursor_name left_ptr"
  spawn "xset s off"
  spawn "xset -dpms"
  spawnOnce "clipcatd"
  spawnOnce "nitrogen --restore"
  spawnOnce "picom -b"
  -- spawnOnce "greenclip daemon"
  spawnOnce "nm-applet"
  spawnOnce "blueman-applet"
  spawnOnce "dunst"
  spawnOnce "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"

--  spawnOnce "redshift-gtk"
-- spawnOnce "libinput-gestures-setup start"
-- spawnOnce "variety"
-- spawn "exec ~/bin/lock.sh"
-- spawnOnce "pa-applet"
-- spawnOnce "exec ~/bin/inhibit_activate"
-- spawnOnce "feh --bg-scale /home/end/Pictures/att.png"
-- spawnOnce "conky -c .config/conky/breaking-bad/AURO-breaking-bad-LUA.conkyrc"
-- spawnOnce "/home/end/bin/wallpaper-wrap.sh"
-- spawnOnce "xrandr --output eDP-1-1 --set 'PRIME Synchronization' 1"
-- spawnOnce "cbatticon -r 10 -i notification -o 'notify-send -i ~/.config/dunst/images/battery-low.png \"Battery\" \"Critical (10%)\" && mpv ~/bin/Low-battery-sound.mp3 &> /dev/null'"
-- spawnOnce "caffeine"
-- spawnOnce "blueberry-tray"
------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = xmonad $ fullscreenSupport $ docks $ ewmh defaults

-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
defaults =
  def
    { -- simple stuff
      terminal = myTerminal,
      focusFollowsMouse = myFocusFollowsMouse,
      clickJustFocuses = myClickJustFocuses,
      borderWidth = myBorderWidth,
      modMask = myModMask,
      workspaces = myWorkspaces,
      normalBorderColor = myNormalBorderColor,
      focusedBorderColor = myFocusedBorderColor,
      -- key bindings
      keys = myKeys,
      mouseBindings = myMouseBindings,
      -- hooks, layouts
      manageHook = myManageHook,
      layoutHook = gaps [(L, 10), (R, 10), (U, 60), (D, 20)] $ spacingRaw True (Border 10 10 10 10) True (Border 10 10 10 10) True $ smartBorders $ myLayout,
      handleEventHook = myEventHook,
      logHook = myLogHook,
      startupHook = myStartupHook >> addEWMHFullscreen
    }

-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help =
  unlines
    [ "The default modifier key is 'super'. Default keybindings:",
      "",
      "-- launching and killing programs",
      "mod-Shift-Enter  Launch xterminal",
      "mod-p            Launch dmenu",
      "mod-Shift-p      Launch gmrun",
      "mod-Shift-c      Close/kill the focused window",
      "mod-Space        Rotate through the available layout algorithms",
      "mod-Shift-Space  Reset the layouts on the current workSpace to default",
      "mod-n            Resize/refresh viewed windows to the correct size",
      "",
      "-- move focus up or down the window stack",
      "mod-Tab        Move focus to the next window",
      "mod-Shift-Tab  Move focus to the previous window",
      "mod-j          Move focus to the next window",
      "mod-k          Move focus to the previous window",
      "mod-m          Move focus to the master window",
      "",
      "-- modifying the window order",
      "mod-Return   Swap the focused window and the master window",
      "mod-Shift-j  Swap the focused window with the next window",
      "mod-Shift-k  Swap the focused window with the previous window",
      "",
      "-- resizing the master/slave ratio",
      "mod-h  Shrink the master area",
      "mod-l  Expand the master area",
      "",
      "-- floating layer support",
      "mod-t  Push window back into tiling; unfloat and re-tile it",
      "",
      "-- increase or decrease number of windows in the master area",
      "mod-comma  (mod-,)   Increment the number of windows in the master area",
      "mod-period (mod-.)   Deincrement the number of windows in the master area",
      "",
      "-- quit, or restart",
      "mod-Shift-q  Quit xmonad",
      "mod-q        Restart xmonad",
      "mod-[1..9]   Switch to workSpace N",
      "",
      "-- Workspaces & screens",
      "mod-Shift-[1..9]   Move client to workspace N",
      "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
      "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
      "",
      "-- Mouse bindings: default actions bound to mouse events",
      "mod-button1  Set the window to floating mode and move by dragging",
      "mod-button2  Raise the window to the top of the stack",
      "mod-button3  Set the window to floating mode and resize by dragging"
    ]
