-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config.font = wezterm.font("FiraCode Nerd Font")
config.font_size = 13
-- For example, changing the color scheme:
-- config.color_scheme = "Nord (Gogh)"
config.color_scheme = "Tokyo Night (Gogh)"
config.enable_tab_bar = true
-- config.enable_wayland = true
-- config.window_decorations = "RESIZE"
-- config.window_background_opacity = 0.95

-- and finally, return the configuration to wezterm
return config
