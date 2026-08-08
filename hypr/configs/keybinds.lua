local M = {}

function M.setup(defaults)
    local defaults = require("configs.defaults")
    local mainMod = "SUPER" -- Sets "Windows" key as main modifier

    hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(defaults.terminal))
    local closeWindowBind = hl.bind(mainMod .. " + Q", hl.dsp.window.close())
    -- closeWindowBind:set_enabled(false)
    hl.bind(mainMod .. " + CTRL + SHIFT + ALT + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
    hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(defaults.fileManager))
    hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(defaults.browser))
    hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(defaults.menu))
    hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))    -- dwindle only

    -- Move focus with mainMod + arrow keys
    hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
    hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
    hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
    hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

    -- Switch workspaces with mainMod + [0-9]
    -- Move active window to a workspace with mainMod + SHIFT + [0-9]
    for i = 1, 10 do
        local key = i % 10 -- 10 maps to key 0
        hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
        hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
    end

    -- Move/resize windows with mainMod + LMB/RMB and dragging
    hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
    hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

    hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))

end

return M
