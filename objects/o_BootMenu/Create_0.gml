// Entering the main menu starts a fresh run, including direct level launches.
item_controllers_reset();

// Carry the final white overlay into the tutorial.
persistent = true;
depth = 100;

enum BootMenuState
{
    MAIN = 12,
    DIFFICULTY = 13,
    SETTINGS = 14,
    CREDITS = 15,
    CONFIRM_EXIT = 16
}

boot_state = BootMenuState.MAIN;
menu_selection = 0;
exit_flash = 0;
if (!variable_global_exists("exhibition_exit_locked")) global.exhibition_exit_locked = false;
menu_mouse_x = device_mouse_x_to_gui(0);
menu_mouse_y = device_mouse_y_to_gui(0);
state_elapsed = 0;
boot_elapsed = 0;

console_lines = [];
line_sound = -1;
transition_sound = -1;
overwrite_started = false;
// Normalized trans1 loudness in 50 ms windows, used to flash with its pulses.
transition_envelope = [
    1, 0.951, 0.958, 0.807, 0.234, 0.197, 0.15, 0.03, 0.477,
    0.998, 0.928, 0.968, 0.64, 0.221, 0.189, 0.12, 0.009, 0.717,
    0.968, 0.947, 0.984, 0.351, 0.211, 0.179, 0.087, 0.001,
    0.891, 0.954, 0.945, 0.892, 0.239, 0.201, 0.164, 0.052, 0.001
];
scroll_timer = 0;
scroll_interval = 0.1;

console_green = make_color_rgb(90, 235, 130);
console_blue = make_color_rgb(145, 210, 255);
console_red = make_color_rgb(255, 55, 65);
console_purple = make_color_rgb(195, 110, 255);
console_white = make_color_rgb(215, 225, 220);
console_dim = make_color_rgb(90, 110, 100);
console_difficulty = 1;

// Replace these placeholders with the final difficulty descriptions.
difficulty_descriptions = [
    "200 health - Slower, less aggressive enemies with more time between attacks. Have some fun.",
    "150 health - The game's intended difficulty.",
    "100 health - Faster, more aggressive enemies with less room for error.",
    "100 health - You will not survive."
];

boot_add_line = function(_text, _color, _play_sfx = true)
{
    // Restart the terminal cue for each new line without overlapping it.
    if (line_sound != -1 && audio_is_playing(line_sound))
    {
        audio_stop_sound(line_sound);
    }
    line_sound = -1;
    if (_play_sfx && !audio_is_playing(sfxInitOpen)
    && !audio_is_playing(sfxInitEnter1)
    && !audio_is_playing(sfxInitEnter2))
    {
        if (transition_sound != -1 && audio_is_playing(transition_sound))
        {
            audio_stop_sound(transition_sound);
        }
        line_sound = audio_play_sound(sfxInitBG, 1, false);
    }

    array_push(console_lines, {
        message: _text,
        tint: _color
    });

    // Keep a bounded history.
    if (array_length(console_lines) > 80)
    {
        array_delete(console_lines, 0, 1);
    }
};

boot_set_state = function(_state)
{
    boot_state = _state;
    state_elapsed = 0;
};

// Use the same geometry for rendering and mouse hit testing.
boot_menu_layout = function()
{
    return { x: 32, y: 82 + (array_length(console_lines) + 1) * 34,
        width: min(900, display_get_gui_width() - 64), row_height: 51,
        text_scale: 1.5, command_scale: 1,
        text_indent: 39 };
};

boot_menu_options = function()
{
    switch (boot_state)
    {
        case BootMenuState.MAIN: return ["Start", "Settings", "Credits", "Exit"];
        case BootMenuState.DIFFICULTY:
            if (!menu_exhibition_active() && variable_global_exists("dev_futile_unlocked") && global.dev_futile_unlocked)
                return ["Easy", "Normal", "Hard", "Futile", "Back"];
            return ["Easy", "Normal", "Hard", "Back"];
        case BootMenuState.SETTINGS:
            return ["Fullscreen: " + (window_get_fullscreen() ? "On" : "Off"),
                "Pixelization: " + (menu_pixelization_active() ? "On" : "Off"), "Back"];
        case BootMenuState.CREDITS: return ["Back"];
        case BootMenuState.CONFIRM_EXIT: return ["Cancel", "Quit game"];
    }
    return [];
};

boot_menu_open = function(_page)
{
    boot_set_state(_page);
    menu_selection = (_page == BootMenuState.DIFFICULTY) ? 1 : 0;
    console_lines = [];
    switch (_page)
    {
        case BootMenuState.MAIN:
            boot_add_line("PS C:\\SYSTEM> .\\menu.exe", console_white, false);
            boot_add_line("ULTRA RAIN", console_green, false);
            break;
        case BootMenuState.DIFFICULTY:
            boot_add_line("PS C:\\SYSTEM> .\\menu.exe start", console_white, false);
            boot_add_line("Select difficulty", console_green, false);
            break;
        case BootMenuState.SETTINGS:
            boot_add_line("PS C:\\SYSTEM> .\\menu.exe settings", console_white, false);
            boot_add_line("Display settings", console_green, false);
            boot_add_line("F11 also toggles fullscreen", console_dim, false);
            break;
        case BootMenuState.CREDITS:
            boot_add_line("PS C:\\SYSTEM> .\\menu.exe credits", console_white, false);
            boot_add_line("ULTRA RAIN", console_green, false);
            boot_add_line("Team One Chance", console_white, false);
            break;
        case BootMenuState.CONFIRM_EXIT:
            boot_add_line("PS C:\\SYSTEM> .\\menu.exe exit", console_white, false);
            boot_add_line("Close ULTRA RAIN?", console_white, false);
            break;
        case 0:
            boot_add_line("PS C:\\SYSTEM> .\\sleep.exe", console_white, false);
            boot_add_line("[OK] sleep.exe initiated", console_green, false);
            break;
    }
};

boot_menu_activate = function()
{
    switch (boot_state)
    {
        case BootMenuState.MAIN:
            switch (menu_selection)
            {
                case 0: boot_menu_open(BootMenuState.DIFFICULTY); break;
                case 1: boot_menu_open(BootMenuState.SETTINGS); break;
                case 2: boot_menu_open(BootMenuState.CREDITS); break;
                case 3:
                    if (global.exhibition_exit_locked) exit_flash = 0.65;
                    else boot_menu_open(BootMenuState.CONFIRM_EXIT);
                    break;
            }
            break;
        case BootMenuState.DIFFICULTY:
            var _back = array_length(boot_menu_options()) - 1;
            if (menu_selection != _back)
            {
                global.game_difficulty = menu_selection;
                console_difficulty = menu_selection;
            }
            boot_menu_open(menu_selection == _back ? BootMenuState.MAIN : 0);
            break;
        case BootMenuState.SETTINGS:
            if (menu_selection == 0) window_set_fullscreen(!window_get_fullscreen());
            else if (menu_selection == 1) menu_toggle_pixelization();
            else boot_menu_open(BootMenuState.MAIN);
            break;
        case BootMenuState.CREDITS:
            boot_menu_open(BootMenuState.MAIN);
            break;
        case BootMenuState.CONFIRM_EXIT:
            if (menu_selection == 0) boot_menu_open(BootMenuState.MAIN);
            else if (global.exhibition_exit_locked)
            {
                boot_menu_open(BootMenuState.MAIN);
                menu_selection = 3;
                exit_flash = 0.65;
            }
            else game_end();
            break;
    }
};

// A full restart clears persistent rooms and can launch straight into the level.
if (variable_global_exists("menu_launch_room") && !is_undefined(global.menu_launch_room))
{
    var _launch_room = global.menu_launch_room;
    global.menu_launch_room = undefined;
    instance_destroy();
    room_goto(_launch_room);
    exit;
}

audio_play_sound(sfxInitOpen, 1, false);
boot_menu_open(BootMenuState.MAIN);
