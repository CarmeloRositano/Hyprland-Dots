-- Window rules. Deploy writes ~/.config/hypr/dms/windowrules.lua

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
