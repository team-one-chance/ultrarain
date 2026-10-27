if (menu_exhibition_active()) exit;
if (keyboard_check(vk_shift)
&& keyboard_check_pressed(ord("R")))
{
    with (o_SeamlessTravel)
    {
        pending = undefined;
        transition_cooldown = 0;

        // The next entry is a fresh room, not a saved-room return.
        if (variable_instance_exists(id, "physics_visited_rooms"))
        {
            var _key = room_get_name(room);

            if (variable_struct_exists(physics_visited_rooms, _key))
            {
                variable_struct_remove(physics_visited_rooms, _key);
            }
        }
    }

    // Discard the current room's stored state before restarting.
    room_persistent = false;
	item_controllers_reset();
    room_restart();
    exit;
}

if (keyboard_check(vk_shift)
&& keyboard_check_pressed(ord("Z")))
{
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

    room_persistent = false;
	item_controllers_reset();
    room_restart();
    exit;
}
