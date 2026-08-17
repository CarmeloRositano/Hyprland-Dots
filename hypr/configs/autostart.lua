hl.on("hyprland.start", function()
	local defaults = require("configs.defaults")

	-- Main
	hl.exec_cmd(defaults.terminal, { workspace = "1" })
	hl.exec_cmd(defaults.browser, { workspace = "1" })
	hl.exec_cmd("kitty -e btop", { workspace = "2 silent" })
	hl.exec_cmd("flatpak run com.spotify.Client", { workspace = "8 silent" })
	hl.exec_cmd("flatpak run com.discordapp.Discord", { workspace = "9 silent" })
	hl.exec_cmd("steam", { workspace = "10 silent" })

	-- Background Daemons
	hl.exec_cmd("dunst")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("waybar")
	hl.exec_cmd("~/.config/waybarr/waybar-autohide")
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("walker --gapplication-service")
	hl.exec_cmd("flatpak run me.amankhanna.opendeck --hide")
	hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
end)
