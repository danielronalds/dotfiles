local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.color_scheme = 'rose-pine'

config.hide_tab_bar_if_only_one_tab = true

config.window_decorations = "RESIZE"

config.default_prog = { '/bin/zsh', '-l' }

config.window_background_opacity = 0.88
config.wayland_window_background_blur = true

config.initial_cols = 110
config.initial_rows = 33

config.font_size = 12

return config
