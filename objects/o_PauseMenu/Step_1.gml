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
// The persistent display controller is suspended with the world while paused.
if (keyboard_check_pressed(vk_f11)) window_set_fullscreen(!window_get_fullscreen());
menu_exhibition_hotkey();

if (keyboard_check_pressed(vk_escape))
{
    if (page != 0) { selected = page == 1 ? 3 : 4; page = 0; selection_age = 0; }
    else pause_resume();
    exit;
}

var _options = pause_options();
var _count = array_length(_options);
var _layout = pause_layout();
var _previous = selected;
var _move = keyboard_check_pressed(vk_down) - keyboard_check_pressed(vk_up);
if (keyboard_check_pressed(vk_tab)) _move = keyboard_check(vk_shift) ? -1 : 1;
selected = (selected + _move + _count) mod _count;
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _hover = -1;
if (abs(_mx - _layout.x) <= _layout.width * 0.5 - 24 * _layout.scale
&& _my >= _layout.row_top && _my < _layout.row_top + _count * _layout.row_height)
    _hover = floor((_my - _layout.row_top) / _layout.row_height);
if ((_mx != last_mouse_x || _my != last_mouse_y) && _hover >= 0) selected = _hover;
last_mouse_x = _mx;
last_mouse_y = _my;
var _click = _hover >= 0 && mouse_check_button_pressed(mb_left);
if (_click) selected = _hover;
if (selected != _previous) selection_age = 0;
if (_click || keyboard_check_pressed(vk_enter)) pause_activate();
