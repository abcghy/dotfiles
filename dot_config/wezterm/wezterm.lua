local wezterm = require("wezterm")

local config = {
    color_scheme = "catppuccin-latte",
    -- color_scheme = "AtomOneLight",
    -- color_scheme = "Catppuccin Mocha",

    -- window_background_opacity = 0.90,
    -- macos_window_background_blur = 20,

    -- Remove title bar but keep the three button
    window_decorations = "INTEGRATED_BUTTONS|RESIZE",
    -- hide_tab_bar_if_only_one_tab = true,
    show_new_tab_button_in_tab_bar = false,
    use_fancy_tab_bar = true,

    -- font
    -- font = wezterm.font('Sarasa Term SC'),
    font = wezterm.font_with_fallback { {
        family = "Maple Mono NF CN",
        weight = "ExtraLight"
    }, {
        family = "Cascadia Code",
        weight = "Light",
    }, {
        family = "Sarasa Term SC",
        -- family = "PingFang SC",
        weight = "Light",
    } },
    font_size = 16.0,

    window_frame = {
        font_size = 16.0,
        font = wezterm.font("FiraCode Nerd Font"),
    },

    send_composed_key_when_left_alt_is_pressed = false,
    send_composed_key_when_right_alt_is_pressed = false,

    default_cwd = wezterm.home_dir,
}
return config
