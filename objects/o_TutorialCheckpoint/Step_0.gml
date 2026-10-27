// Wait until all room Create events have finished before restoring visibility.
if (checkpoint_layers_pending)
{
    restore_checkpoint_layers();
    checkpoint_layers_pending = false;
}
else if (!is_struct(checkpoint_layers)) save_checkpoint_layers();

var _player = instance_find(o_Player, 0);
if (!instance_exists(_player)) exit;
if (_player.pHP <= 0 || _player.grinder_dying) exit;
if (variable_global_exists("dev_freecam") && global.dev_freecam) exit;

// Group 0 is the big room's three scouts and three drones.
// Wait for every queued spawn and every spawned enemy, including stragglers.
if (!big_room_cleared && array_length(big_room_enemies) > 0)
{
    var _pending = false;
    with (o_DoorEnemySpawn) if (ambush_group == 0) _pending = true;
    for (var _i = 0; _i < array_length(big_room_enemies); _i++)
    {
        if (instance_exists(big_room_enemies[_i])) _pending = true;
    }

    // Save a grounded position rather than an airborne killing-blow location.
    // on_ground is local to the player's Step, not an instance variable.
    // Check the current feet position here so Step order cannot leave stale state.
    var _grounded = false;
    if (!_pending && _player.phy_speed_y >= 0)
    {
        var _feet_y = _player.y + _player.ground_check_y_offset;
        _grounded = collision_point(
            _player.x - _player.ground_check_x_offset, _feet_y,
            o_Block, false, true
        ) != noone || collision_point(
            _player.x + _player.ground_check_x_offset, _feet_y,
            o_Block, false, true
        ) != noone;
    }
    if (!_pending && _grounded)
    {
        big_room_cleared = true;
        respawn_x = _player.x;
        respawn_y = _player.y;
        save_checkpoint_layers();
    }
}

// Keep the latest tutorial checkpoint available during travel to another room.
global.menu_checkpoint = { x: respawn_x, y: respawn_y, cleared: big_room_cleared, layers: checkpoint_layers };
