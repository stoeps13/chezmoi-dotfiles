-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config.font = wezterm.font("FiraCode Nerd Font")
config.font_size = 13
-- For example, changing the color scheme:
config.color_scheme = "Tokyo Night (Gogh)"
-- alternative dark themes
-- config.color_scheme = "Nord (Gogh)"
-- config.color_scheme = "Tartan (terminal.sexy)"
-- config.color_scheme = "Tomorrow Night"
-- Light theme
-- config.color_scheme = "tokyonight-day"
config.enable_tab_bar = true
-- config.enable_wayland = true
-- config.window_decorations = "RESIZE"
-- config.window_background_opacity = 0.95

-- and finally, return the configuration to wezterm
return config
