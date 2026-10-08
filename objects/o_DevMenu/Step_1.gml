global.dev_resume_input = false;
if (!enabled) exit;

if (is_undefined(spawn_position) && instance_exists(o_Player))
    spawn_position = [o_Player.x, o_Player.y];
if (keyboard_check_pressed(collision_key)) global.dev_collisions = !global.dev_collisions;
if (keyboard_check_pressed(vk_f4)) time_paused = !time_paused;
if (keyboard_check_pressed(vk_f5))
{
    time_paused = true;
    step_requested = true;
    if (opened) resume_game();
    global.dev_resume_input = false;
}

if (keyboard_check_pressed(menu_key))
{
    if (opened) resume_game();
    else
    {
        cursor_position = [mouse_x, mouse_y];
        opened = true;
        freeze_world();
    }
    update_time();
    update_enemy_freeze();
    exit;
}

if (!opened)
{
    update_time();
    update_enemy_freeze();
    exit;
}

if (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(vk_backspace) || keyboard_check_pressed(vk_left))
{
    if (page != 0) { page = 0; selected = 0; }
    else resume_game();
    update_time();
    exit;
}
var _actions = menu_actions();
row_count = array_length(_actions);
selected = clamp(selected, 0, row_count - 1);
if (keyboard_check_pressed(vk_up)) selected = (selected + row_count - 1) mod row_count;
if (keyboard_check_pressed(vk_down)) selected = (selected + 1) mod row_count;
var _layout = menu_layout();
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _hover = floor(((_my - _layout.top) / _layout.scale - 88) / row_height);
var _activate = keyboard_check_pressed(vk_enter);
if (_mx >= _layout.left && _mx <= _layout.left + _layout.width && _hover >= 0 && _hover < row_count)
{
    if (mouse_check_button_pressed(mb_left)) { selected = _hover; _activate = true; }
}
if (_activate) run_action(_actions[selected]);
row_count = array_length(menu_actions());
