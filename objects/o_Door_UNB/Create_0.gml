door_state = 0; // 0 = closed, 1 = opening, 2 = open

//train_exit = true;

image_index = 0;
image_speed = 0;

var door_width = 32;  // CHANGE: blocking panel width
var door_height = 64; // CHANGE: blocking panel height

var fix = physics_fixture_create();

physics_fixture_set_box_shape(
    fix,
    door_width / 2,
    door_height / 2
);

physics_fixture_set_density(fix, 0);
physics_fixture_set_friction(fix, 0.5);
physics_fixture_set_restitution(fix, 0);
physics_fixture_set_collision_group(fix, 1);

// Place the rectangle at the sprite canvas centre,
// regardless of where you set the sprite origin.
door_fixture = physics_fixture_bind_ext(
    fix,
    id,
    sprite_get_width(sprite_index) / 2 - sprite_get_xoffset(sprite_index),
    sprite_get_height(sprite_index) / 2 - sprite_get_yoffset(sprite_index)
);

physics_fixture_delete(fix);

door_open = function()
{
    if (door_state != 0) return;

    door_state = 1;
    image_index = 0;
    image_speed = 1;
};

// 3 = closing
door_close = function()
{
	show_debug_message(
    "Door closing requested. State: "
    + string(door_state)
);
    if (door_state != 2) return;

    // Restore the closed door's collision.
    if (door_fixture == -1)
    {
        var _fix = physics_fixture_create();

        physics_fixture_set_box_shape(_fix, 16, 32);
        physics_fixture_set_density(_fix, 0);
        physics_fixture_set_friction(_fix, 0.5);
        physics_fixture_set_restitution(_fix, 0);
        physics_fixture_set_collision_group(_fix, 1);

        door_fixture = physics_fixture_bind_ext(
            _fix,
            id,
            sprite_get_width(sprite_index) / 2
                - sprite_get_xoffset(sprite_index),
            sprite_get_height(sprite_index) / 2
                - sprite_get_yoffset(sprite_index)
        );

        physics_fixture_delete(_fix);
    }

    door_state = 3;
    image_index = image_number - 1;
    image_speed = -1;
};