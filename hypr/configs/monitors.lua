hl.config({
    render = {
        cm_auto_hdr = 0,   -- Disables unstable automatic HDR profile drops for SDR games
    }
})


hl.monitor({
    output            = "DP-3",
    mode              = "3440x1440@239.98900",
    position          = "0x0",
    scale             = 1,
    bitdepth          = 10,
    cm                = "hdr",
    sdrbrightness     = 1.0,      -- Set to 1.0 to map SDR white accurately to HDR reference white
    sdrsaturation     = 1.0,      -- Faux-saturation can break color mapping, stick to 1.0
    sdr_min_luminance = 0.005,    -- Slightly above 0.0 keeps true deep blacks without crushed details
    sdr_max_luminance = 203,      -- Forces correct EOTF reference mapping (standard for HDR reference white)
})


-- Origjinal config for DP-3, but with SDR settings
-- hl.monitor({
--     output   = "DP-3",
--     mode     = "3440x1440@239.98900",
--     position = "0x0",
--     scale    = 1,
--     bitdepth = 10,
--     cm = "hdr",
--     sdrbrightness = 1.2,
--     sdrsaturation = 0.98,
--     sdr_min_luminance = 0.0,
-- })

-- Disabled config for DP-3, but with SDR settings
-- hl.monitor({
--     output   = "DP-3",
--     mode     = "3440x1440@239.98900",
--     position = "0x0",
--     scale    = 1,
--     bitdepth = 8,
-- })

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
