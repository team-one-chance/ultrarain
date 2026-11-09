function menu_exhibition_active()
{
    return variable_global_exists("exhibition_exit_locked") && global.exhibition_exit_locked;
}

// Primary gameplay bindings. Negative values represent mouse buttons.
function controls_defaults()
{
    return { left: ord("A"), right: ord("D"), up: ord("W"), jump: vk_space,
        slide: vk_control, dash: vk_shift, slam: ord("S"), heal: ord("Q"),
        pistol: ord("1"), sword: ord("2"), interact: ord("E"),
        fire: -1, coin: -2, pin: -3 };
}

function controls_names()
{
    return ["left", "right", "up", "jump", "slide", "dash", "slam", "heal",
        "pistol", "sword", "interact", "fire", "coin", "pin"];
}

function controls_labels()
{
    return ["Move left", "Move right", "Up / mantle", "Jump", "Slide", "Dash", "Slam", "Heal",
        "Pistol", "Sword", "Interact", "Fire / sword", "Coin / parry", "Pin coin"];
}

// Shared two-column options and geometry for the main and pause menus.
function controls_menu_options(_page, _capture)
{
    var _names = controls_names();
    var _labels = controls_labels();
    var _options = [];
    var _start = _page * 8;
    for (var _i = _start; _i < min(_start + 8, array_length(_names)); _i++)
        array_push(_options, _labels[_i] + ": " + (_capture == _names[_i]
            ? "Press a key or mouse button" : controls_key_name(controls_key(_names[_i]))));
    array_push(_options, "<", ">", "Reset defaults", "Back");
    return _options;
}

function controls_menu_item_layout(_index, _action_count, _layout)
{
    var _scale = _layout.scale;
    if (_index < _action_count)
        return { x: _layout.x + ((_index mod 2 == 0) ? -145 : 145) * _scale,
            y: _layout.row_top + (floor(_index / 2) * 56 + 26) * _scale,
            width: 268 * _scale, height: 48 * _scale };
    var _nav = _index - _action_count;
    // Page arrows share a row; reset and back are centered on separate rows.
    var _nav_x = [-25, 25, 0, 0];
    var _nav_y = [245, 245, 290, 330];
    var _nav_width = [36, 36, 250, 100];
    return { x: _layout.x + _nav_x[_nav] * _scale,
        y: _layout.row_top + _nav_y[_nav] * _scale,
        width: _nav_width[_nav] * _scale, height: 38 * _scale };
}

// 0 means no input; -4 cancels; -1 through -3 are mouse buttons.
function controls_capture_key()
{
    if (keyboard_check_pressed(vk_escape)) return -4;
    for (var _key = 32; _key <= 90; _key++)
        if ((_key == vk_space || (_key >= vk_left && _key <= vk_down)
            || (_key >= ord("0") && _key <= ord("9")) || (_key >= ord("A") && _key <= ord("Z")))
            && keyboard_check_pressed(_key)) return _key;
    if (keyboard_check_pressed(vk_control)) return vk_control;
    if (keyboard_check_pressed(vk_shift)) return vk_shift;
    if (keyboard_check_pressed(vk_alt)) return vk_alt;
    for (var _button = 1; _button <= 3; _button++)
        if (mouse_check_button_pressed(_button)) return -_button;
    return 0;
}

function controls_init()
{
    if (variable_global_exists("controls_bindings")) return;
    global.controls_bindings = controls_defaults();
    var _names = controls_names();
    ini_open("controls.ini");
    for (var _i = 0; _i < array_length(_names); _i++)
    {
        var _default = variable_struct_get(global.controls_bindings, _names[_i]);
        var _key = ini_read_real("bindings", _names[_i], _default);
        if ((_key >= 32 && _key <= 90) || _key == vk_control || _key == vk_shift || _key == vk_alt
            || (_key >= -3 && _key <= -1))
            variable_struct_set(global.controls_bindings, _names[_i], _key);
    }
    ini_close();
}

function controls_key(_name)
{
    controls_init();
    return variable_struct_get(global.controls_bindings, _name);
}

function controls_down(_name)
{
    if (!training_action_allowed(_name)) return false;
    var _key = controls_key(_name);
    return _key < 0 ? mouse_check_button(-_key) : keyboard_check(_key);
}

function controls_pressed(_name)
{
    if (!training_action_allowed(_name)) return false;
    var _key = controls_key(_name);
    return _key < 0 ? mouse_check_button_pressed(-_key) : keyboard_check_pressed(_key);
}

// Keep the original arrow-key alternatives unless an arrow is assigned elsewhere.
function controls_key_unassigned(_key)
{
    var _names = controls_names();
    for (var _i = 0; _i < array_length(_names); _i++)
        if (controls_key(_names[_i]) == _key) return false;
    return true;
}

function controls_key_name(_key)
{
    switch (_key)
    {
        case -1: return "Mouse left";
        case -2: return "Mouse right";
        case -3: return "Mouse middle";
        case vk_space: return "Space";
        case vk_control: return "Ctrl";
        case vk_shift: return "Shift";
        case vk_alt: return "Alt";
        case vk_left: return "Left arrow";
        case vk_right: return "Right arrow";
        case vk_up: return "Up arrow";
        case vk_down: return "Down arrow";
    }
    return chr(_key);
}

// Exchange an existing assignment to keep every action reachable.
function controls_save()
{
    var _names = controls_names();
    ini_open("controls.ini");
    for (var _i = 0; _i < array_length(_names); _i++)
        ini_write_real("bindings", _names[_i], controls_key(_names[_i]));
    ini_close();
}

function controls_assign(_name, _key)
{
    controls_init();
    var _old = controls_key(_name);
    var _names = controls_names();
    for (var _i = 0; _i < array_length(_names); _i++)
        if (_names[_i] != _name && controls_key(_names[_i]) == _key)
            variable_struct_set(global.controls_bindings, _names[_i], _old);
    variable_struct_set(global.controls_bindings, _name, _key);
    controls_save();
}

// These defaults preserve the current low-cost rendering and wide framing.
function display_settings_init()
{
    if (variable_global_exists("settings_performance")) return;
    ini_open("display.ini");
    global.settings_performance = ini_read_real("display", "performance", 1) != 0;
    global.settings_ultrawide = ini_read_real("display", "ultrawide", 1) != 0;
    ini_close();
}

function display_performance_active()
{
    display_settings_init();
    return global.settings_performance;
}

// Shared rendering budget for the menu, TESTING, and every gameplay room.
function display_settings_profile()
{
    display_settings_init();
    var _width = global.settings_ultrawide ? 2160 : 1440; // World pixels; wider framing reveals more level on each side.
    var _height = 720; // World pixels; both aspect ratios keep the same vertical framing.
    return {
        width: _width, height: _height,
        render_scale: global.settings_performance ? 1 : 1.5, // Output pixels per world pixel; Quality restores the former rendering scale.
        gui_height: 1080, // Logical interface pixels; independent of graphics quality.
        light_resolution: global.settings_performance ? 0.5 : 1, // Light-map dimensions relative to the world camera.
        light_pixel_budget: global.settings_performance ? 259200 : _width * _height, // Maximum illumination pixels; Quality uses the full world view.
        bloom_resolution: global.settings_performance ? 0.5 : 1, // Glow-buffer dimensions relative to the application surface.
        bloom_limit_to_world: global.settings_performance // Performance caps glow work even on larger render targets.
    };
}

function display_settings_apply(_resize_window = false)
{
    var _profile = display_settings_profile();
    var _cam = view_camera[0];
    if (_cam != -1 && (camera_get_view_width(_cam) != _profile.width
    || camera_get_view_height(_cam) != _profile.height))
    {
        // Preserve the camera center when switching horizontal field of view.
        var _center_x = camera_get_view_x(_cam) + camera_get_view_width(_cam) * 0.5;
        var _center_y = camera_get_view_y(_cam) + camera_get_view_height(_cam) * 0.5;
        camera_set_view_size(_cam, _profile.width, _profile.height);
        camera_set_view_pos(_cam, _center_x - _profile.width * 0.5, _center_y - _profile.height * 0.5);
    }
    view_wport[0] = round(_profile.width * _profile.render_scale);
    view_hport[0] = round(_profile.height * _profile.render_scale);
    var _gui_width = _profile.width * _profile.gui_height / _profile.height;
    if (display_get_gui_width() != _gui_width || display_get_gui_height() != _profile.gui_height)
        display_set_gui_size(_gui_width, _profile.gui_height);
    if (surface_exists(application_surface))
    {
        if (surface_get_width(application_surface) != view_wport[0]
        || surface_get_height(application_surface) != view_hport[0])
            surface_resize(application_surface, view_wport[0], view_hport[0]);
    }
    if (_resize_window)
    {
        var _ratio = _profile.width / _profile.height;
        var _window_height = max(1, floor(min(720, display_get_width() * 0.9 / _ratio,
            display_get_height() * 0.9))); // Window pixels; fit inside 90% of the monitor, including room for borders.
        window_set_size(round(_window_height * _ratio), _window_height);
        window_center();
    }
}

function display_settings_save()
{
    ini_open("display.ini");
    ini_write_real("display", "performance", global.settings_performance);
    ini_write_real("display", "ultrawide", global.settings_ultrawide);
    ini_close();
}

function menu_toggle_graphics()
{
    display_settings_init();
    global.settings_performance = !global.settings_performance;
    display_settings_save();
    display_settings_apply();
}

function menu_toggle_aspect_ratio()
{
    display_settings_init();
    global.settings_ultrawide = !global.settings_ultrawide;
    display_settings_save();
    display_settings_apply(true);
}

function menu_display_options()
{
    display_settings_init();
    return ["Fullscreen: " + (window_get_fullscreen() ? "On" : "Off"),
        "Pixelization: " + (menu_pixelization_active() ? "On" : "Off"),
        "Mouse combo heal: " + (global.heal_mouse_combo ? "On" : "Off"),
        "Graphics: " + (global.settings_performance ? "Performance" : "Quality"),
        "Aspect ratio: " + (global.settings_ultrawide ? "Ultrawide (3:1)" : "Original (2:1)"),
        "Controls", "Back"];
}

function menu_display_hint(_selection)
{
    if (_selection == 3) return "Performance reduces GPU load; Quality restores finer detail.";
    if (_selection == 4) return "Ultrawide shows more level; vertical framing stays the same.";
    return "F11 also toggles fullscreen";
}

function menu_pixelization_active()
{
    return variable_global_exists("settings_pixelization") && global.settings_pixelization;
}

function menu_toggle_pixelization()
{
    global.settings_pixelization = !menu_pixelization_active();
    with (o_Lighting)
        pixelation_size = global.settings_pixelization ? pixelation_alternate_size : 1.0;
}

function menu_exhibition_hotkey()
{
    if (!keyboard_check(vk_control) || !keyboard_check(vk_shift)
    || !keyboard_check_pressed(vk_f10)) return;
    global.exhibition_exit_locked = !menu_exhibition_active();
    if (global.exhibition_exit_locked)
    {
        with (o_DevMenu) disable_tools();
        global.basher_tuner_open = false;
        global.basher_tuner_capture_mouse = false;
        global.basher_tuner_motion = 0;
    }
}
