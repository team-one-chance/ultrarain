global.dev_resume_input = false;
if (instance_exists(o_PauseMenu) && o_PauseMenu.opened) exit;
menu_exhibition_hotkey();
if (menu_exhibition_active())
{
    update_enemy_freeze();
    exit;
}
if (!enabled) exit;

if (keyboard_check_pressed(vk_f6))
{
    run_action(11);
    update_time();
    update_enemy_freeze();
    exit;
}

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

if (map_open)
{
    if (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(vk_backspace))
    {
        map_open = false;
        exit;
    }
    if (keyboard_check_pressed(ord("R"))) map_rebuild();
    if (!map_scan_ready) map_update_scan();
    if (!map_cache_ready || !surface_exists(map_cache_surface)) exit;
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _layout = map_layout();
    var _inside = _mx >= 0 && _mx < display_get_gui_width()
        && _my >= 80 && _my < display_get_gui_height() - 32;
    if (keyboard_check_pressed(vk_home))
    {
        map_zoom = 1;
        map_center_x = (map_bounds[0] + map_bounds[2]) * 0.5;
        map_center_y = (map_bounds[1] + map_bounds[3]) * 0.5;
    }
    else if (_inside)
    {
        var _wheel = mouse_wheel_up() - mouse_wheel_down();
        if (_wheel != 0)
        {
            var _anchor_x = map_center_x + (_mx - _layout.x) / _layout.scale;
            var _anchor_y = map_center_y + (_my - _layout.y) / _layout.scale;
            map_zoom = clamp(map_zoom * power(map_zoom_step, _wheel), 1, map_zoom_max);
            _layout = map_layout();
            map_center_x = _anchor_x - (_mx - _layout.x) / _layout.scale;
            map_center_y = _anchor_y - (_my - _layout.y) / _layout.scale;
        }
        if (mouse_check_button(mb_middle))
        {
            map_center_x -= (_mx - map_mouse_x) / _layout.scale;
            map_center_y -= (_my - map_mouse_y) / _layout.scale;
        }
    }
    map_mouse_x = _mx;
    map_mouse_y = _my;
    _layout = map_layout();
    var _tx = map_center_x + (_mx - _layout.x) / _layout.scale;
    var _ty = map_center_y + (_my - _layout.y) / _layout.scale;
    if (_inside && _tx >= 0 && _tx < room_width && _ty >= 0 && _ty < room_height
        && mouse_check_button_pressed(mb_left) && !is_undefined(map_player))
    {
        thaw_world();
        teleport_player([_tx, _ty]);
        // Return from freecam and frame the destination immediately.
        global.dev_freecam = false;
        freecam_restore_layers();
        var _cam = view_camera[0];
        if (_cam != -1)
            camera_set_view_pos(_cam,
                clamp(_tx - camera_get_view_width(_cam) * 0.5, 0, max(0, room_width - camera_get_view_width(_cam))),
                clamp(_ty - camera_get_view_height(_cam) / 1.4, 0, max(0, room_height - camera_get_view_height(_cam))));
        resume_game();
        update_time();
        update_enemy_freeze();
    }
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
