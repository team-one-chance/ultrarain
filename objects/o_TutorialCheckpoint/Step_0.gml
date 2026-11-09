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
if (checkpoint_syringes_pending && instance_exists(_player))
{
    _player.medkit_owned = checkpoint_medkit_owned;
    _player.syringe_count = checkpoint_syringe_count;
    _player.syringe_max = checkpoint_syringe_max;
    checkpoint_syringes_pending = false;
}
if (!instance_exists(_player) || _player.pHP <= 0 || _player.grinder_dying)
{
    vent_skip_state = 0;
    vent_skip_alpha = 0;
    exit;
}
if (variable_global_exists("dev_freecam") && global.dev_freecam) exit;

if (ari_retry_visit_pending)
{
    ari_retry_check_seconds = max(0, ari_retry_check_seconds - delta_time / 1000000);
    if (ari_retry_check_seconds <= 0)
    {
        ari_retry_check_seconds = 1; // Seconds between safety checks if the current checkpoint surroundings are blocked.
        var _ari = noone;
        with (oAri) if (object_index == oAri) _ari = id; // Samuel inherits the cinematic but must never receive Ari's checkpoint visit.
        if (!instance_exists(_ari)) _ari = instance_create_depth(respawn_x, respawn_y, -2, oAri);
        if (_ari.ari_prepare_checkpoint_visit(respawn_x, respawn_y)) ari_retry_visit_pending = false;
    }
}

// The skip is available throughout the passage and stops before the chute.
if (vent_skip_state == 0 && vent_skip_available(_player) && controls_pressed("interact"))
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
            var _destination_x = max(6080, vent_skip_hold_x); // Never move a player near the exit backwards.
            var _destination_y = 2623; // Feet one pixel above the vent floor.
            // Do not move the player if a future room edit blocks the short collider.
            if (collision_rectangle(_destination_x - 29, _destination_y - 27,
                _destination_x + 30, _destination_y - 1, o_Block, false, true) == noone)
            {
                // Apply the passage's reveal triggers skipped by the teleport.
                var _skip_start_x = vent_skip_hold_x;
                with (o_Reveal)
                {
                    if (x < _skip_start_x || x > _destination_x
                        || y + reveal_trigger_height * 0.5 < _destination_y - 27
                        || y - reveal_trigger_height * 0.5 > _destination_y) continue;
                    var _layer = layer_get_id(layer_to_hide);
                    if (_layer != -1) { layer_set_visible(_layer, false); layer_hidden = true; }
                }
                with (o_Show)
                {
                    if (x < _skip_start_x || x > _destination_x
                        || y + reveal_trigger_height * 0.5 < _destination_y - 27
                        || y - reveal_trigger_height * 0.5 > _destination_y) continue;
                    var _layer = layer_get_id(layer_to_hide);
                    if (_layer != -1) { layer_set_visible(_layer, true); layer_hidden = false; }
                }
                vent_skip_used = true;
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

// Wait until the whole player is inside so the closing vent cannot trap or push them.
var _boss_vent_right = boss_vent_x + sprite_get_width(s_Chute_Break);
if (!boss_vent_closed && _player.bbox_left > _boss_vent_right
    && _player.bbox_top < boss_vent_y + sprite_get_height(s_Chute_Break)
    && _player.bbox_bottom > boss_vent_y)
{
    boss_vent_closed = true;
    // A solid wall uses the original cover art and cannot be destroyed by any attack.
    instance_create_depth(boss_vent_x, boss_vent_y, -1, o_Block,
        { sprite_index: s_Chute_Break, visible: true, image_speed: 0 });
    with (oDrone) nav_grid_dirty = true;
    world_sfx_play(sfxDoorClose, boss_vent_x, boss_vent_y, 0.75);
}

// The existing dark-room reveal marks the entrance to group 0's arena.
if (!big_room_cleared && big_room_ambush_elapsed < 0)
{
    var _entered_big_room = false;
    with (o_Reveal)
    {
        if (layer_to_hide == "dark_room" && point_in_rectangle(_player.x, (_player.bbox_top + _player.bbox_bottom) * 0.5,
            x - reveal_trigger_width * 0.5, y - reveal_trigger_height * 0.5,
            x + reveal_trigger_width * 0.5, y + reveal_trigger_height * 0.5))
            _entered_big_room = true;
    }
    if (_entered_big_room)
    {
        big_room_ambush_elapsed = 0;
        x = _player.x;
        y = _player.y; // Anchor the pending encounter's alarm at the doorway until its enemies spawn.
        _player.start_ambush_alarm_sfx(id);
    }
}
if (!big_room_cleared && big_room_ambush_elapsed >= 0 && !big_room_ambush_spawned)
{
    big_room_ambush_elapsed += max(0, (variable_global_exists("dev_delta_time")
        ? global.dev_delta_time : delta_time) / 1000000);
    if (big_room_ambush_elapsed >= big_room_ambush_delay)
    {
        big_room_ambush_spawned = true;
        with (o_DoorEnemySpawn)
        {
            if (ambush_group != 0) continue;
            var _enemy = instance_create_layer(x, y, "Instances", enemy_object);
            array_push(_player.ambush_alarm_enemies, _enemy);
            array_push(other.big_room_enemies, _enemy);
            instance_destroy();
        }
        // Hand the alarm to the enemies so it stops after the encounter is cleared.
        for (var _i = array_length(_player.ambush_alarm_doors) - 1; _i >= 0; _i--)
        {
            if (_player.ambush_alarm_doors[_i] == id)
                array_delete(_player.ambush_alarm_doors, _i, 1);
        }
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
        save_checkpoint_syringes(_player);
    }
}

// Keep the latest tutorial checkpoint available during travel to another room.
global.menu_checkpoint = { x: respawn_x, y: respawn_y, cleared: big_room_cleared, layers: checkpoint_layers,
    first_door_open: checkpoint_first_door_open, medkit_owned: checkpoint_medkit_owned,
    syringe_count: checkpoint_syringe_count, syringe_max: checkpoint_syringe_max };
