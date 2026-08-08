hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})

hl.config({
    input = {
        kb_layout = "fr",
        follow_mouse = 1,
        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.
        touchpad = {
            natural_scroll = true,
        },
        kb_options = "ctrl:nocaps",
    },
    -- Example per-device config
    -- See https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs for more
})

