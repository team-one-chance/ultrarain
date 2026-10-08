game_over_age += (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) / 1000000;
update_layout();
if (game_over_age < game_over_delay) exit;

button_hover = point_in_rectangle(
    device_mouse_x_to_gui(0), device_mouse_y_to_gui(0),
    button_left, button_top, button_right, button_bottom
);

if ((button_hover && mouse_check_button_pressed(mb_left))
|| keyboard_check_pressed(vk_enter))
{
    // Match the existing terminal restart: discard saved travel/run state.
    global.demo_travel_state = undefined;
    global.demo_took_damage = false;
    global.demo_used_healing = false;
    global.demo_finish_time = 0;
    keyboard_string = "";
    game_restart();
    exit;
}
