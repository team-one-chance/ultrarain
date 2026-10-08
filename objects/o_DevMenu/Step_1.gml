if (!enabled) exit;

if (is_undefined(spawn_position) && instance_exists(o_Player))
    spawn_position = [o_Player.x, o_Player.y];

if (keyboard_check_pressed(collision_key))
    global.dev_collisions = !global.dev_collisions;

if (keyboard_check_pressed(menu_key) || (opened && keyboard_check_pressed(vk_escape)))
{
    if (opened) resume_game();
    else
    {
        cursor_position = [mouse_x, mouse_y];
        if (surface_exists(application_surface))
        {
            paused_surface = surface_create(surface_get_width(application_surface), surface_get_height(application_surface));
            surface_copy(paused_surface, 0, 0, application_surface);
        }
        // Record only active instances; preserve any pre-existing deactivation.
        paused_instances = [];
        with (all)
        {
            if (id != other.id)
                array_push(other.paused_instances, id);
        }
        physics_pause_enable(true);
        instance_deactivate_all(true);
        opened = true;
    }
    exit;
}

if (!opened) exit;
if (keyboard_check_pressed(vk_up)) selected = (selected + row_count - 1) mod row_count;
if (keyboard_check_pressed(vk_down)) selected = (selected + 1) mod row_count;

var _left = max(8, (display_get_gui_width() - panel_width) * 0.5);
var _top = max(8, (display_get_gui_height() - (row_count * row_height + 112)) * 0.5);
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _hover = floor((_my - _top - 64) / row_height);
if (_mx >= _left && _mx <= _left + panel_width && _hover >= 0 && _hover < row_count)
{
    if (mouse_check_button_pressed(mb_left)) { selected = _hover; run_action(selected); }
}

// Enter works even when the mouse is resting over a row.
if (opened && keyboard_check_pressed(vk_enter)) run_action(selected);
