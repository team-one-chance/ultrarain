if (break_requested && !broken)
{
    broken = true;

    physics_remove_fixture(id, door_fixture);
    door_fixture = -1;

    // Find the door sprite's area in room coordinates.
    var _x1 =
        x - sprite_get_xoffset(sprite_index) * image_xscale;

    var _y1 =
        y - sprite_get_yoffset(sprite_index) * image_yscale;

    var _x2 =
        _x1 + sprite_get_width(sprite_index) * image_xscale;

    var _y2 =
        _y1 + sprite_get_height(sprite_index) * image_yscale;

    // Scatter small fragments across the whole door.
    repeat (28)
    {
        instance_create_depth(
            random_range(min(_x1, _x2), max(_x1, _x2)),
            random_range(min(_y1, _y2), max(_y1, _y2)),
            depth - 1,
            o_DoorDebris
        );
    }

    flash_elapsed = 0;
}

if (broken)
{
    flash_elapsed += delta_time / 1000000;

    // Spawn enemies after the three flashes finish.
    if (flash_elapsed >= flash_duration)
    {
        var _group = ambush_group;

        with (o_DoorEnemySpawn)
        {
            if (ambush_group == _group)
            {
                instance_create_layer(
                    x, y, "Instances", enemy_object
                );

                instance_destroy();
            }
        }

        instance_destroy();
    }
}
