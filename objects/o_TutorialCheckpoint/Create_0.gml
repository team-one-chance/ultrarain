// Room-local progress; only Retry carries it into a rebuilt tutorial.
respawn_x = 1184;
respawn_y = 192;
big_room_cleared = false;
big_room_enemies = [];
checkpoint_layers = undefined;
checkpoint_layers_pending = false;

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
        with (o_Chute_Breakable)
{
    var _is_secret = variable_instance_exists(id, "secret_hard_only")
        && secret_hard_only;

    if (ambush_group == 0 && !_is_secret)
        instance_destroy();
}
    }

    var _cam = view_camera[0];
    if (_cam != -1)
    {
        camera_set_view_pos(_cam,
            respawn_x - camera_get_view_width(_cam) / 2,
            respawn_y - camera_get_view_height(_cam) / 1.4);
    }
}
