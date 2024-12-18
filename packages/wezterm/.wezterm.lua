local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action

config.mouse_bindings = {
	{
		event = { Down = { streak = 1, button = { WheelUp = 1 } } },
		mods = "NONE",
		action = act.ScrollByCurrentEventWheelDelta,
	},
	{
		event = { Down = { streak = 1, button = { WheelDown = 1 } } },
		mods = "NONE",
		action = act.ScrollByCurrentEventWheelDelta,
	},
}

config.color_scheme = "DanQing (base16)"
config.font_size = 14

config.enable_tab_bar = false

config.window_decorations = "RESIZE"

return config
