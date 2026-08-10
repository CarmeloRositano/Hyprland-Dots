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

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

hl.window_rule({
		name  = "btop",
		match = { class = "btop"},

		float = true,
})

hl.window_rule({
    name  = "updates",
    match = { class = "updates"},

    float = true,
})

hl.window_rule({
		name  = "impala",
		match = { class = "impala" },

		float = true,
})

hl.window_rule({
    name = "bluetui",
    match = { class = "bluetui"},

    float = true,
})

hl.window_rule({
    name = "wiremix",
    match = { class = "wiremix"},

    float = true,
})

-- Custom

-- Make all workspaces persistant
for i = 1, 9 do
    hl.workspace_rule({ workspace = i, persistent = true})
end

-- Set workspace 1 to main monitor
hl.workspace_rule({ workspace = "1", monitor = "DP-1", default = true, persistent = true})

-- Set workspace 2 to always be 2nd monitor
hl.workspace_rule({ workspace = "2", monitor = "HDMI-A-1", default = true, persistent = true})

-- Autostart rules
hl.window_rule({
		match = { class = "^spotify$" },
		workspace = "8 silent",
})

hl.window_rule({
    match = { class = "^discord$" },
    workspace = "9 silent",
})

hl.window_rule({
    match = { class = "^steam$" },
    workspace = "10 silent",
})
