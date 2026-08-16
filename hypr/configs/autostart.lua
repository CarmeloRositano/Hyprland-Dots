hl.on("hyprland.start", function()
	-- Main
	hl.exec_cmd("kitty", { workspace = "1" })
	hl.exec_cmd("flatpak run app.zen_browser.zen", { workspace = "1" })
	hl.exec_cmd("kitty -e btop", { workspace = "2 silent" })
	hl.exec_cmd("flatpak run com.spotify.Client", { workspace = "8 silent" })
	hl.exec_cmd("flatpak run com.discordapp.Discord", { workspace = "9 silent" })
	hl.exec_cmd("steam", { workspace = "10 silent" })

	-- Background Daemons
	hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
end)
