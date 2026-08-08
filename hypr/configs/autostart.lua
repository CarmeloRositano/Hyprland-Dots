hl.on("hyprland.start", function ()
    local defaults = require("configs.defaults")

    -- Start Locked
    hl.exec_cmd("hyprlock")

    -- Main
    hl.exec_cmd(defaults.terminal)

    -- Background Daemons
    hl.exec_cmd("hypridle")
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper")

--   hl.exec_cmd("nm-applet")
--   hl.exec_cmd("waybar & hyprpaper & firefox")
end)
