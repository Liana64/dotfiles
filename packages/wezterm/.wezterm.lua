local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.color_scheme = "DanQing (base16)"
config.font_size = 14

config.enable_tab_bar = false

config.window_decorations = "RESIZE"

return config
