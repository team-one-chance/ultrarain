if (break_requested && !broken)
{
    broken = true;
    with (oDrone) nav_grid_dirty = true;
    world_sfx_play(sfxDoorBreaking, x, y, 0.8);

    var _alarm_player = instance_nearest(x, y, o_Player);
    if (room == LE_PWR)
    {
        var _samuel = instance_find(oSamuel, 0);
        if (!instance_exists(_samuel)) _samuel = instance_create_depth(0, 0, -2, oSamuel);
        _samuel.samuel_arm_entrance(id, _alarm_player); // Open the entrance now; Samuel waits until the player actually crosses inside.
    }
    var _samuel_pending = room == LE_PWR && instance_exists(oSamuel)
        && !oSamuel.samuel_encounter_finished;
    if (instance_exists(_alarm_player) && !_samuel_pending) _alarm_player.start_ambush_alarm_sfx(id);

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
    // LE_PWR's door never spawns enemies. Samuel alone releases its group after the conversation.
    if (room == LE_PWR)
    {
        if (instance_exists(oSamuel) && !oSamuel.samuel_encounter_finished) exit;
        instance_destroy();
        exit;
    }
    flash_elapsed += (variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000;

    // Spawn enemies after the three flashes finish.
    if (flash_elapsed >= flash_duration)
    {
        var _group = ambush_group;
        var _alarm_player = instance_nearest(x, y, o_Player);

        with (o_DoorEnemySpawn)
        {
            if (ambush_group == _group)
            {
                var _spawned_enemy = instance_create_layer(
                    x, y, "Instances", enemy_object
                );
                if (breaker_entrance_slam && enemy_object == oEnemy_Breaker)
                {
                    _spawned_enemy.breaker_start_entrance_slam();
                }
                if (instance_exists(_alarm_player))
                {
                    array_push(_alarm_player.ambush_alarm_enemies, _spawned_enemy);
                }
                if (room == LE_TUTORIAL_WIP && ambush_group == 0
                && instance_exists(o_TutorialCheckpoint))
                {
                    array_push(o_TutorialCheckpoint.big_room_enemies, _spawned_enemy);
                }

                instance_destroy();
            }
        }

        instance_destroy();
    }
}

