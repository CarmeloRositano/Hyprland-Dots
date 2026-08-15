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

hl.window_rule({
    match = { class = "^Splashtop$" },
		opacity = "1.0",
})

hl.window_rule({
    match = { class = "^plex$" },
    opacity = "1.0",
})

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

-- DP-1: workspaces 1 and 3-10
for i = 1, 10 do
    if i ~= 2 then
        hl.workspace_rule({
            workspace = i,
            monitor = "DP-3",
            persistent = true,
        })
    end
end

-- Workspace 2 is permanently assigned to the 2nd monitor
hl.workspace_rule({
    workspace = "2",
    monitor = "HDMI-A-1",
    default = true,
    persistent = true
})

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

hl.window_rule({
    match = { title = "^qs-launcher$" },
    float = true,
    center = true,
    size = "600 500",
		stay_focused = true,
})
