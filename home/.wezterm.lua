local wezterm = require 'wezterm'

local config = wezterm.config_builder()

local appearance = {
    color_scheme = 'rose-pine',
    font_size = 12,
    opacity = 0.88
}

if wezterm.target_triple:find('linux') ~= nil then
    -- linux config
    config.wayland_window_background_blur = true
elseif wezterm.target_triple:find('darwin') ~= nil then
    -- macos config
    config.macos_window_background_blur = 20

    appearance.opacity = 0.9
    appearance.color_scheme = 'rose-pine-moon'
    appearance.font_size = 14
elseif wezterm.target_triple == 'x86_64-pc-windows-msvc' then
    -- windows configuration
end

config.hide_tab_bar_if_only_one_tab = true

-- Applying platform specific appearance
config.window_background_opacity = appearance.opacity
config.color_scheme = appearance.color_scheme
config.font_size = appearance.font_size

config.window_decorations = "RESIZE"
config.window_padding = {
    left = 10,
    right = 10,
    top = 5,
    bottom = 5
}

config.default_prog = { '/bin/zsh', '-l' }

config.initial_cols = 110
config.initial_rows = 33

return config
