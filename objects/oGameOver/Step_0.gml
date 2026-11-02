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
    if (room == LE_TUTORIAL_WIP && instance_exists(o_TutorialCheckpoint))
    {
        var _checkpoint = instance_find(o_TutorialCheckpoint, 0);
        global.tutorial_checkpoint_retry = {
            x: _checkpoint.respawn_x, y: _checkpoint.respawn_y,
            cleared: _checkpoint.big_room_cleared, layers: _checkpoint.checkpoint_layers,
            first_door_open: _checkpoint.checkpoint_first_door_open || _checkpoint.first_door_is_open(),
            medkit_owned: _checkpoint.checkpoint_medkit_owned,
            syringe_count: _checkpoint.checkpoint_syringe_count, syringe_max: _checkpoint.checkpoint_syringe_max
        };
        global.demo_travel_state = undefined;
        with (o_SeamlessTravel)
        {
            pending = undefined;
            transition_cooldown = 0;
            if (variable_instance_exists(id, "physics_visited_rooms"))
            {
                var _key = room_get_name(room);
                if (variable_struct_exists(physics_visited_rooms, _key))
                {
                    variable_struct_remove(physics_visited_rooms, _key);
                }
            }
        }
        // Rebuild the room and its physics instead of resuming a dead player.
        room_persistent = false;
        keyboard_string = "";
        room_restart();
        exit;
    }
    // Match the existing terminal restart: discard saved travel/run state.
    global.demo_travel_state = undefined;
    global.demo_took_damage = false;
    global.demo_used_healing = false;
    global.demo_finish_time = 0;
    keyboard_string = "";
    game_restart();
    exit;
}
