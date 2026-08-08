hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.monitor({
    output = "eDP-1",
    mode = "preferred",
    position = "auto",
    scale = "1.25",
})

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "1",
    mirror = "eDP-1",
})

local programs = {
    terminal = "kitty",
    menu = "wofi --show drun",
    browser = "zen-browser",
    ide = "zeditor",
}

hl.on("hyprland.start", function()
    hl.exec_cmd("quickshell")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("hyprpaper")
end)

return programs
