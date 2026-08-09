-- See https://wiki.hyprland.org/Configuring/Keywords/

local programs = require("hyprland.env")

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(programs.terminal .. " -e tmux"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exit())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(programs.menu))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(programs.ide))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(programs.browser))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(programs.browser .. " -p Tadao"))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("pkill quickshell; quickshell"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind("Print", hl.dsp.exec_cmd("mkdir -p ~/screenshots && hyprshot -m region -o ~/screenshots"))
hl.bind(mainMod .. " + Escape", hl.dsp.global("quickshell:powermenu_toggle"))

-- Dynamic Island
hl.bind(mainMod .. " + N", hl.dsp.global("quickshell:island_notifications"))
hl.bind(mainMod .. " + C", hl.dsp.global("quickshell:island_controlcenter"))
hl.bind(mainMod .. " + M", hl.dsp.global("quickshell:island_media"))
hl.bind(mainMod .. " + I", hl.dsp.global("quickshell:island_hour"))
hl.bind(mainMod .. " + H", hl.dsp.global("quickshell:island_strip"))
hl.bind(mainMod .. " + SHIFT + I", hl.dsp.global("quickshell:island_cycle"))

-- Move focus with mainMod + arrow key
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
hl.bind(mainMod .. " + ampersand", hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. " + eacute", hl.dsp.focus({ workspace = 2 }))
hl.bind(mainMod .. " + quotedbl", hl.dsp.focus({ workspace = 3 }))
hl.bind(mainMod .. " + apostrophe", hl.dsp.focus({ workspace = 4 }))
hl.bind(mainMod .. " + parenleft", hl.dsp.focus({ workspace = 5 }))
hl.bind(mainMod .. " + minus", hl.dsp.focus({ workspace = 6 }))
hl.bind(mainMod .. " + egrave", hl.dsp.focus({ workspace = 7 }))
hl.bind(mainMod .. " + underscore", hl.dsp.focus({ workspace = 8 }))
hl.bind(mainMod .. " + ccedilla", hl.dsp.focus({ workspace = 9 }))
hl.bind(mainMod .. " + agrave", hl.dsp.focus({ workspace = 10 }))

-- Move active window to a workspace with mainMod + SHIFT + [0-9]
hl.bind(mainMod .. " + SHIFT + ampersand", hl.dsp.window.move({ workspace = 1 }))
hl.bind(mainMod .. " + SHIFT + eacute", hl.dsp.window.move({ workspace = 2 }))
hl.bind(mainMod .. " + SHIFT + quotedbl", hl.dsp.window.move({ workspace = 3 }))
hl.bind(mainMod .. " + SHIFT + apostrophe", hl.dsp.window.move({ workspace = 4 }))
hl.bind(mainMod .. " + SHIFT + parenleft", hl.dsp.window.move({ workspace = 5 }))
hl.bind(mainMod .. " + SHIFT + minus", hl.dsp.window.move({ workspace = 6 }))
hl.bind(mainMod .. " + SHIFT + egrave", hl.dsp.window.move({ workspace = 7 }))
hl.bind(mainMod .. " + SHIFT + underscore", hl.dsp.window.move({ workspace = 8 }))
hl.bind(mainMod .. " + SHIFT + ccedilla", hl.dsp.window.move({ workspace = 9 }))
hl.bind(mainMod .. " + SHIFT + agrave", hl.dsp.window.move({ workspace = 10 }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { drag = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { drag = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume",  hl.dsp.global("quickshell:volume_up"),      { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.global("quickshell:volume_down"),    { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.global("quickshell:volume_mute"),    { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.global("quickshell:mic_mute"),       { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.global("quickshell:brightness_up"),  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.global("quickshell:brightness_down"),{ locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.global("quickshell:media_next"),   { locked = true })
hl.bind("XF86AudioPause", hl.dsp.global("quickshell:media_toggle"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.global("quickshell:media_toggle"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.global("quickshell:media_prev"),   { locked = true })

