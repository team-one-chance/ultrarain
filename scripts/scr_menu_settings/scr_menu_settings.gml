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
