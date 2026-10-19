// DEVELOPMENT CONFIG: set enabled to false for a release build.
enabled = true;
menu_key = vk_f1;
collision_key = vk_f2;
row_height = 30;
panel_width = 600;
menu_scale = 1.35; // Scales text, spacing, panel, and mouse targets together.

if (!variable_global_exists("dev_invincible")) global.dev_invincible = false;
if (!variable_global_exists("dev_collisions")) global.dev_collisions = false;
global.dev_resume_input = false;
if (!enabled)
{
    global.dev_invincible = false;
    global.dev_collisions = false;
}
opened = false;
selected = 0;
page = 0;
row_count = 6;
world_frozen = false;
time_paused = false;
time_rate = 1;
base_game_speed = game_get_speed(gamespeed_fps);
step_requested = false;
global.dev_freeze_enemies = false;
paused_surface = -1;
paused_instances = [];
test_position = undefined;
spawn_position = undefined;
cursor_position = [0, 0];

// Shared layout keeps drawn rows and mouse targets aligned at every GUI size.
menu_layout = function()
{
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _base_height = row_count * row_height + 136;
    var _scale = min(menu_scale, min((_gw - 16) / panel_width, (_gh - 16) / _base_height));
    _scale = max(0.1, _scale);
    return {
        scale: _scale,
        width: panel_width * _scale,
        height: _base_height * _scale,
        left: max(8, (_gw - panel_width * _scale) * 0.5),
        top: max(8, (_gh - _base_height * _scale) * 0.5)
    };
};

freeze_world = function()
{
    if (world_frozen) return;
    with (o_Player)
    {
        stop_movement_sfx();
        stop_electric_wires_sfx();
        stop_molten_lava_sfx();
        stop_gear_grinder_sfx();
        stop_ambush_alarm_sfx();
    }
    with (o_DoorController) stop_wire_flash_sfx();
    with (o_TrainRide) stop_tram_sfx();
    if (surface_exists(application_surface))
    {
        paused_surface = surface_create(surface_get_width(application_surface), surface_get_height(application_surface));
        surface_copy(paused_surface, 0, 0, application_surface);
    }
    paused_instances = [];
    with (all)
        if (id != other.id) array_push(other.paused_instances, id);
    physics_pause_enable(true);
    instance_deactivate_all(true);
    world_frozen = true;
};

thaw_world = function()
{
    if (!world_frozen) return;
    for (var i = 0; i < array_length(paused_instances); ++i)
        instance_activate_object(paused_instances[i]);
    paused_instances = [];
    physics_pause_enable(false);
    world_frozen = false;
    if (surface_exists(paused_surface)) surface_free(paused_surface);
    paused_surface = -1;
};

resume_game = function()
{
    if (!opened) return;
    opened = false;
    if (!time_paused) thaw_world();
    global.dev_resume_input = true;
    keyboard_clear(vk_enter);
    mouse_clear(mb_left);
};

update_time = function()
{
    if (opened || time_paused)
    {
        // Keep menu input responsive while simulation instances are suspended.
        game_set_speed(base_game_speed, gamespeed_fps);
        if (step_requested)
        {
            step_requested = false;
            thaw_world();
        }
        else freeze_world();
        return;
    }

    thaw_world();
    game_set_speed(max(1, round(base_game_speed * time_rate)), gamespeed_fps);
};

// Freeze AI and path playback while keeping enemies visible and damageable.
update_enemy_freeze = function()
{
    with (oEnemyParent)
    {
        if (global.dev_freeze_enemies)
        {
            if (!variable_instance_exists(id, "dev_saved_motion") || is_undefined(dev_saved_motion))
                dev_saved_motion = [image_speed, path_speed, hspeed, vspeed];
            image_speed = 0;
            path_speed = 0;
            hspeed = 0;
            vspeed = 0;
        }
        else if (variable_instance_exists(id, "dev_saved_motion") && !is_undefined(dev_saved_motion))
        {
            image_speed = dev_saved_motion[0];
            path_speed = dev_saved_motion[1];
            hspeed = dev_saved_motion[2];
            vspeed = dev_saved_motion[3];
            dev_saved_motion = undefined;
        }
    }
};

menu_actions = function()
{
    switch (page)
    {
        case 1: return [1, 2, 3, 4, 99];
        case 2: return [5, 6, 7, 8, 9, 99];
        case 3: return [20, 21, 22, 23, 24, 99];
        case 4: return [30, 31, 34, 33, 36, 35, 32, 99];
        case 5: return [0, 99];
    }
    return [101, 102, 103, 104, 105, 10];
};

menu_label = function(_action)
{
    switch (_action)
    {
        case 101: return "Player";
        case 102: return "World / teleport";
        case 103: return "Enemies";
        case 104: return "Time";
        case 105: return "Debug / collisions";
        case 99: return "Back to categories";
        case 0: return "Collision overlay [F2]: " + (global.dev_collisions ? "ON" : "OFF");
        case 1: return "Invincibility: " + (global.dev_invincible ? "ON" : "OFF");
        case 2: return "Refill health and coins";
        case 3: return "Equip pistol / reset cooldown";
        case 4: return "Equip sword / reset cooldown";
        case 5: return "Teleport to cursor captured on opening";
        case 6: return "Save current test position";
        case 7: return "Teleport to saved position" + (is_undefined(test_position) ? " (none saved)" : "");
        case 8: return "Teleport to room spawn";
        case 9: return "Restart room";
        case 10: return "Close menu";
		case 11: return "Freecam [F6]: " + (global.dev_freecam ? "ON" : "OFF");
        case 20: return "Spawn grunt at captured cursor";
        case 21: return "Spawn drone at captured cursor";
        case 22: return "Spawn miniboss at captured cursor";
        case 23: return "Freeze enemy AI: " + (global.dev_freeze_enemies ? "ON" : "OFF");
        case 24: return "Clear all enemies";
        case 30: return "Simulation pause [F4]: " + (time_paused ? "ON" : "OFF");
        case 31: return "Advance one frame [F5]";
        case 32: return "Speed: 100%" + (time_rate == 1 ? " (selected)" : "");
        case 33: return "Speed: 300%" + (time_rate == 3 ? " (selected)" : "");
        case 34: return "Speed: 400%" + (time_rate == 4 ? " (selected)" : "");
        case 35: return "Speed: 150%" + (time_rate == 1.5 ? " (selected)" : "");
        case 36: return "Speed: 200%" + (time_rate == 2 ? " (selected)" : "");
    }
    return "";
};

teleport_player = function(_position)
{
    if (is_undefined(_position) || !instance_exists(o_Player)) return;
    with (o_Player)
    {
        phy_position_x = _position[0];
        phy_position_y = _position[1];
        phy_speed_x = 0;
        phy_speed_y = 0;
        damage_knockback_timer = 0;
        damage_knockback_pending = false;
        is_slamming = false;
        slam_last_y = _position[1];
    }
};

run_action = function(_action)
{
    if (_action >= 101 && _action <= 105) { page = _action - 100; selected = 0; return; }
    if (_action == 99) { page = 0; selected = 0; return; }
    if (_action == 0) { global.dev_collisions = !global.dev_collisions; return; }
    if (_action == 1) { global.dev_invincible = !global.dev_invincible; return; }
    if (_action == 23) { global.dev_freeze_enemies = !global.dev_freeze_enemies; return; }
    if (_action == 30) { time_paused = !time_paused; return; }
    if (_action >= 32 && _action <= 36)
    {
        var _time_rates = [1, 3, 4, 1.5, 2];
        time_rate = _time_rates[_action - 32];
        return;
    }
	if (_action == 11)
    {
        thaw_world();
        freecam_restore_layers();
        global.dev_freecam = !global.dev_freecam;
        time_paused = false;
        step_requested = false;
        resume_game();
        return;
    }
    if (_action == 7 && is_undefined(test_position)) return;
    if (_action == 31)
    {
        time_paused = true;
        step_requested = true;
        resume_game();
        return;
    }
    // Mutation needs active instances; freeze again before gameplay if time is paused.
    thaw_world();
    switch (_action)
    {
        case 2:
            with (o_Player) { pHP = pHP_max; coin_count = coin_max; }
            break;
        case 3:
        case 4:
            with (o_Player)
            {
                weapon_type = (_action == 3) ? "pistol" : "sword";
                aim_rig_mode = (_action == 3) ? AimRigMode.ONE_HANDED : AimRigMode.TWO_HANDED;
                sword_swing_timer = 0;
                sword_swing_pending_hit = false;
                weapon_fire_timer = 0;
            }
            break;
        case 5: teleport_player(cursor_position); break;
        case 6:
            if (instance_exists(o_Player)) test_position = [o_Player.x, o_Player.y];
            break;
        case 7: teleport_player(test_position); break;
        case 8: teleport_player(spawn_position); break;
        case 9:
            time_paused = false;
            time_rate = 1;
            resume_game();
            room_restart();
            return;
        case 20: instance_create_depth(cursor_position[0], cursor_position[1], 0, oEnemy_TEMP); break;
        case 21: instance_create_depth(cursor_position[0], cursor_position[1], 0, oDrone); break;
        case 22: instance_create_depth(cursor_position[0], cursor_position[1], 0, oMiniBoss); break;
        case 24:
            with (oEnemyParent) instance_destroy();
            with (oEnemyDroneBullet) instance_destroy();
            break;
    }
    update_enemy_freeze();
    resume_game();
    if (time_paused) freeze_world();
};

// Debug freecam: camera movement uses real seconds.
global.dev_freecam = false;
global.dev_freecam_speed = 650;
global.dev_freecam_fast_speed = 2200;
freecam_layer_states = [];

freecam_restore_layers = function()
{
    for (var _i = 0; _i < array_length(freecam_layer_states); _i++)
    {
        var _saved = freecam_layer_states[_i];
        if (layer_exists(_saved.layer))
            layer_set_visible(_saved.layer, _saved.was_visible);
    }
    freecam_layer_states = [];
};
