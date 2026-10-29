var _dt = min(0.1, delta_time / 1000000);
if (!opened)
{
    if (!keyboard_check_pressed(vk_escape) || room == LE_MENU
    || instance_exists(o_BootMenu) || instance_exists(oGameOver)) exit;
    var _player = instance_find(o_Player, 0);
    if (!instance_exists(_player) || _player.pHP <= 0 || _player.grinder_dying) exit;
    controller = instance_find(o_DevMenu, 0);
    if (!instance_exists(controller) || controller.opened) exit;
    opened = true;
    page = 0;
    selected = 0;
    menu_age = 0;
    selection_age = 0;
    last_mouse_x = device_mouse_x_to_gui(0);
    last_mouse_y = device_mouse_y_to_gui(0);
    controller.freeze_world(id);
    game_set_speed(controller.base_game_speed, gamespeed_fps);
    exit;
}

menu_age += _dt;
selection_age += _dt;
if (controls_capture != "")
{
    var _bind = controls_capture_key();
    if (_bind == -4)
    {
        controls_capture = "";
        keyboard_clear(vk_escape);
        exit;
    }
    if (_bind != 0)
    {
        controls_assign(controls_capture, _bind);
        controls_capture = "";
        if (_bind > 0) keyboard_clear(_bind); else mouse_clear(-_bind);
    }
    exit;
}
// The persistent display controller is suspended with the world while paused.
if (keyboard_check_pressed(vk_f11)) window_set_fullscreen(!window_get_fullscreen());
menu_exhibition_hotkey();

if (keyboard_check_pressed(vk_escape))
{
    if (page == 3) { page = 1; selected = 3; selection_age = 0; }
    else if (page != 0) { selected = page == 1 ? 3 : 4; page = 0; selection_age = 0; }
    else pause_resume();
    exit;
}

var _options = pause_options();
var _count = array_length(_options);
var _layout = pause_layout();
var _previous = selected;
var _move = keyboard_check_pressed(vk_down) - keyboard_check_pressed(vk_up);
if (keyboard_check_pressed(vk_tab))
    selected = (selected + (keyboard_check(vk_shift) ? -1 : 1) + _count) mod _count;
else if (page == 3)
{
    var _action_count = _count - 4;
    var _horizontal = keyboard_check_pressed(vk_right) - keyboard_check_pressed(vk_left);
    if (selected < _action_count)
    {
        if (_horizontal != 0 && selected + _horizontal >= 0 && selected + _horizontal < _action_count
            && floor((selected + _horizontal) / 2) == floor(selected / 2)) selected += _horizontal;
        if (_move > 0) selected = selected + 2 < _action_count ? selected + 2 : _action_count;
        else if (_move < 0) selected = selected >= 2 ? selected - 2 : _action_count + 3;
    }
    else
    {
        var _nav = selected - _action_count;
        if (_horizontal < 0 && _nav == 1) _nav = 0;
        if (_horizontal > 0 && _nav == 0) _nav = 1;
        if (_move < 0) selected = _nav < 2 ? _action_count - 1 : _action_count + (_nav == 2 ? 0 : 2);
        else if (_move > 0) selected = _nav < 2 ? _action_count + 2 : (_nav == 2 ? _action_count + 3 : 0);
        else selected = _action_count + _nav;
    }
}
else selected = (selected + _move + _count) mod _count;
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _hover = -1;
if (page == 3)
{
    for (var _i = 0; _i < _count; _i++)
    {
        var _item = controls_menu_item_layout(_i, _count - 4, _layout);
        if (abs(_mx - _item.x) <= _item.width * 0.5 && abs(_my - _item.y) <= _item.height * 0.5)
        {
            _hover = _i;
            break;
        }
    }
}
else if (abs(_mx - _layout.x) <= _layout.width * 0.5 - 24 * _layout.scale
&& _my >= _layout.row_top && _my < _layout.row_top + _count * _layout.row_height)
    _hover = floor((_my - _layout.row_top) / _layout.row_height);
if ((_mx != last_mouse_x || _my != last_mouse_y) && _hover >= 0) selected = _hover;
last_mouse_x = _mx;
last_mouse_y = _my;
var _click = _hover >= 0 && mouse_check_button_pressed(mb_left);
if (_click) selected = _hover;
if (selected != _previous) selection_age = 0;
if (_click || keyboard_check_pressed(vk_enter)) pause_activate();
