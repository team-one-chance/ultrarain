// Room-local progress; only Retry carries it into a rebuilt tutorial.
respawn_x = 1184;
respawn_y = 192;
big_room_cleared = false;
big_room_enemies = [];

if (variable_global_exists("tutorial_checkpoint_retry")
&& is_struct(global.tutorial_checkpoint_retry))
{
    var _retry = global.tutorial_checkpoint_retry;
    respawn_x = _retry.x;
    respawn_y = _retry.y;
    big_room_cleared = _retry.cleared;
    global.tutorial_checkpoint_retry = undefined;

    with (o_Player)
    {
        phy_position_x = other.respawn_x;
        phy_position_y = other.respawn_y;
        phy_speed_x = 0;
        phy_speed_y = 0;
        footstep_last_x = x;
    }

    if (big_room_cleared)
    {
        with (o_DoorEnemySpawn) if (ambush_group == 0) instance_destroy();
        with (o_Door_Breakable) if (ambush_group == 0) instance_destroy();
        with (o_Chute_Breakable) if (ambush_group == 0) instance_destroy();
    }

    var _cam = view_camera[0];
    if (_cam != -1)
    {
        camera_set_view_pos(_cam,
            respawn_x - camera_get_view_width(_cam) / 2,
            respawn_y - camera_get_view_height(_cam) / 1.4);
    }
}
