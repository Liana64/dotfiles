local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.color_scheme = "Chalkboard"
config.font_size = 16

config.enable_tab_bar = false

config.window_decorations = "RESIZE"

return config
