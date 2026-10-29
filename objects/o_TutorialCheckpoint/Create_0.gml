// Room-local progress; only Retry carries it into a rebuilt tutorial.
respawn_x = 1184;
respawn_y = 192;
big_room_cleared = false;
big_room_enemies = [];
checkpoint_layers = undefined;
checkpoint_layers_pending = false;
checkpoint_first_door_open = false; // Remember the first tutorial door across a retry.
checkpoint_first_door_pending = false;
vent_skip_state = 0; // 0 = idle, 1 = fade out, 2 = fade in.
vent_skip_alpha = 0; // Black overlay opacity, from 0 to 1.
vent_skip_fade_seconds = 0.4; // Seconds per fade; larger values slow the transition.
vent_skip_hold_x = 0;
vent_skip_hold_y = 0;
vent_skip_used = false; // A completed skip cannot be triggered again in this room.
vent_skip_start_x = 1024; // Room pixels: start of the vent passage.
vent_skip_end_x = 6171; // Room pixels: Breaker chute at the end of the passage.
vent_skip_available = function(_player)
{
    return instance_exists(_player) && _player.pHP > 0 && !_player.grinder_dying
        && !vent_skip_used && _player.is_sliding
        && _player.x >= vent_skip_start_x && _player.x <= vent_skip_end_x
        && _player.y >= 2592 && _player.y <= 2632 && _player.hacking_controller == noone;
};

first_door_is_open = function()
{
    var _door = instance_nearest(1600, 128, o_Door_UNB);
    return instance_exists(_door) && point_distance(_door.x, _door.y, 1600, 128) < 8
        && (_door.door_state == 1 || _door.door_state == 2);
};

restore_first_door = function()
{
    var _door = instance_nearest(1600, 128, o_Door_UNB);
    if (instance_exists(_door) && point_distance(_door.x, _door.y, 1600, 128) < 8)
    {
        _door.door_state = 2;
        _door.image_index = _door.image_number - 1;
        _door.image_speed = 0;
        if (_door.door_fixture != -1)
        {
            physics_remove_fixture(_door, _door.door_fixture);
            _door.door_fixture = -1;
        }
        with (oDrone) nav_grid_dirty = true;
    }
    var _controller = instance_nearest(1504, 128, o_DoorController);
    if (instance_exists(_controller) && point_distance(_controller.x, _controller.y, 1504, 128) < 8)
    {
        _controller.controller_state = 3;
        _controller.sprite_index = _controller.broken_sprite;
        _controller.image_index = 0;
        _controller.image_speed = 0;
    }
};

// Store layer names, not room-specific layer IDs, which change on restart.
save_checkpoint_layers = function()
{
    var _layers = {};
    with (o_Reveal)
    {
        var _layer = layer_get_id(layer_to_hide);
        if (_layer != -1) variable_struct_set(_layers, layer_to_hide, layer_get_visible(_layer));
    }
    with (o_Show)
    {
        var _layer = layer_get_id(layer_to_hide);
        if (_layer != -1) variable_struct_set(_layers, layer_to_hide, layer_get_visible(_layer));
    }
    with (o_revealUnder)
    {
        for (var _i = 0; _i < array_length(under_background_layers); _i++)
        {
            var _layer = under_background_layers[_i];
            if (_layer != -1) variable_struct_set(_layers, layer_get_name(_layer), layer_get_visible(_layer));
        }
    }
    checkpoint_layers = _layers;
};

restore_checkpoint_layers = function()
{
    if (!is_struct(checkpoint_layers)) return;
    var _names = variable_struct_get_names(checkpoint_layers);
    for (var _i = 0; _i < array_length(_names); _i++)
    {
        var _layer = layer_get_id(_names[_i]);
        if (_layer != -1) layer_set_visible(_layer, variable_struct_get(checkpoint_layers, _names[_i]));
    }
};

if (variable_global_exists("tutorial_checkpoint_retry")
&& is_struct(global.tutorial_checkpoint_retry))
{
    var _retry = global.tutorial_checkpoint_retry;
    respawn_x = _retry.x;
    respawn_y = _retry.y;
    big_room_cleared = _retry.cleared;
    if (variable_struct_exists(_retry, "first_door_open"))
    {
        checkpoint_first_door_open = _retry.first_door_open;
        checkpoint_first_door_pending = checkpoint_first_door_open;
    }
    if (variable_struct_exists(_retry, "layers"))
    {
        checkpoint_layers = _retry.layers;
        checkpoint_layers_pending = is_struct(checkpoint_layers);
    }
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
