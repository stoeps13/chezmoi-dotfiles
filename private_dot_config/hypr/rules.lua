--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

-- Float Necessary Windows
hl.window_rule({ match = { class = "(xdg-desktop-portal-gtk|xdg-desktop-portal-kde|xdg-desktop-portal-hyprland)(.*)" }, float = true })
hl.window_rule({ match = { class = "(hyprpolkitagent|qt-sudo)(.*)" }, float = true })
hl.window_rule({ match = { initial_title = "(Rename|File Operation Progress|Extract)(.*)" }, float = true, size = { "(monitor_w*0.25)", "(monitor_h*0.125)" } })
hl.window_rule({ match = { initial_class = "hyprland-share-picker" }, float = true })

-- Window transparency
hl.window_rule({ match = { initial_class = "thunar" }, opacity = 0.9 })
