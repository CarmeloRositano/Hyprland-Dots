hl.monitor({
    output   = "DP-3",
    mode     = "3440x1440@239.98900",
    position = "0x0",
    scale    = 1,
    bitdepth = 10,
    cm = "hdr",
    sdrbrightness = 1.2,
    sdrsaturation = 0.98,
    sdr_min_luminance = 0.0,
})

hl.monitor({
    output   = "HDMI-A-1",
    mode     = "2560x720@60.26600",
    position = "440x1440",
    scale    = "1",
})

hl.monitor({
    output   = "HDMI-A-2",
    disabled = true,
})
