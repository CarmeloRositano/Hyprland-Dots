-- Optional per-user keybind overrides (managed by DMS). Loaded after default binds.
hl.bind("SUPER + F", hl.dsp.exec_cmd("flatpak run app.zen_browser.zen"))
hl.bind("SUPER + E", hl.dsp.exec_cmd("nautilus"))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind("SUPER  + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER  + mouse:273", hl.dsp.window.resize(), { mouse = true })
