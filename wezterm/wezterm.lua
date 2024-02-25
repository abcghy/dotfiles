local wezterm = require 'wezterm'

local config = {
    color_scheme = "catppuccin-mocha",

    window_background_opacity = 0.90,
    macos_window_background_blur = 20,

    -- Remove title bar but keep the three button
    window_decorations = "INTEGRATED_BUTTONS|RESIZE",
    hide_tab_bar_if_only_one_tab = true,
    show_new_tab_button_in_tab_bar = false,
    use_fancy_tab_bar = true,

    -- font
    font = wezterm.font('Sarasa Term SC'),
    font_size = 18.0,

    window_frame = {
        font_size = 16.0,
        font = wezterm.font('FiraCode Nerd Font')
    }
}
return config
