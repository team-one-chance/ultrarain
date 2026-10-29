// Wait until all room Create events have finished before restoring visibility.
if (checkpoint_first_door_pending)
{
    restore_first_door();
    checkpoint_first_door_pending = false;
}
if (first_door_is_open()) checkpoint_first_door_open = true;
if (checkpoint_layers_pending)
{
    restore_checkpoint_layers();
    checkpoint_layers_pending = false;
}
else if (!is_struct(checkpoint_layers)) save_checkpoint_layers();

var _player = instance_find(o_Player, 0);
if (!instance_exists(_player) || _player.pHP <= 0 || _player.grinder_dying)
{
    vent_skip_state = 0;
    vent_skip_alpha = 0;
    exit;
}
if (variable_global_exists("dev_freecam") && global.dev_freecam) exit;

// The optional skip starts after the medkit and entry reveal triggers, and
// ends before the Breaker chute so its normal break/ambush sequence still runs.
var _vent_skip_available = _player.is_sliding && _player.x >= 1450 && _player.x <= 2000
    && _player.y >= 2592 && _player.y <= 2632 && _player.hacking_controller == noone;
if (vent_skip_state == 0 && _vent_skip_available && controls_pressed("interact"))
{
    vent_skip_state = 1;
    vent_skip_hold_x = _player.phy_position_x;
    vent_skip_hold_y = _player.phy_position_y;
    var _skip_key = controls_key("interact");
    if (_skip_key < 0) mouse_clear(-_skip_key); else keyboard_clear(_skip_key);
}
if (vent_skip_state != 0)
{
    var _skip_dt = max(0, (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) / 1000000);
    _player.phy_position_x = vent_skip_hold_x;
    _player.phy_position_y = vent_skip_hold_y;
    _player.phy_speed_x = 0;
    _player.phy_speed_y = 0;
    if (vent_skip_state == 1)
    {
        vent_skip_alpha = min(1, vent_skip_alpha + _skip_dt / vent_skip_fade_seconds);
        if (vent_skip_alpha >= 1)
        {
            var _destination_x = 6080; // Room pixels: inside the passage before the chute.
            var _destination_y = 2623; // Feet one pixel above the vent floor.
            // Do not move the player if a future room edit blocks the short collider.
            if (collision_rectangle(_destination_x - 29, _destination_y - 27,
                _destination_x + 30, _destination_y - 1, o_Block, false, true) == noone)
            {
                vent_skip_hold_x = _destination_x;
                vent_skip_hold_y = _destination_y;
                _player.player_set_collider(true);
                _player.is_sliding = true;
                _player.slide_direction = 1;
                _player.phy_position_x = vent_skip_hold_x;
                _player.phy_position_y = vent_skip_hold_y;
                _player.footstep_last_x = vent_skip_hold_x;
                var _skip_camera = view_camera[0];
                if (_skip_camera != -1)
                    camera_set_view_pos(_skip_camera, vent_skip_hold_x - camera_get_view_width(_skip_camera) / 2,
                        vent_skip_hold_y - camera_get_view_height(_skip_camera) / 1.4);
            }
            vent_skip_state = 2;
        }
    }
    else
    {
        vent_skip_alpha = max(0, vent_skip_alpha - _skip_dt / vent_skip_fade_seconds);
        if (vent_skip_alpha <= 0) vent_skip_state = 0;
    }
}

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

    // Wait for a grounded player before saving the cleared encounter.
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
        respawn_x = 1056; // Room pixels: centre of the vent entrance.
        respawn_y = 2527; // Feet one pixel above the intact vent blocks on retry.
        save_checkpoint_layers();
    }
}

// Keep the latest tutorial checkpoint available during travel to another room.
global.menu_checkpoint = { x: respawn_x, y: respawn_y, cleared: big_room_cleared, layers: checkpoint_layers,
    first_door_open: checkpoint_first_door_open };
