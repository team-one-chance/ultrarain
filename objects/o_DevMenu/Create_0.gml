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

// Teleport map: cached room artwork, independent of the gameplay camera.
map_open = false;
map_items = [];
map_player = undefined;
map_zoom = 1;
map_zoom_step = 1.25;
map_zoom_max = 64;
map_center_x = 0;
map_center_y = 0;
map_mouse_x = 0;
map_mouse_y = 0;
map_bounds = [0, 0, room_width, room_height];
map_fit_padding = 96;
map_layout = function()
{
    var _w = display_get_gui_width();
    var _h = display_get_gui_height();
    return { x: _w * 0.5, y: (_h + 48) * 0.5,
        scale: min(max(1, _w - 32) / max(1, map_bounds[2] - map_bounds[0]),
            max(1, _h - 128) / max(1, map_bounds[3] - map_bounds[1])) * map_zoom };
};

// Only sprite snapshots belong on the pause path; never scan tile cells on F1.
map_sprites = [];
map_scan_layers = [];
map_scan_layer = 0;
map_scan_cell = 0;
map_scan_started = false;
map_scan_ready = false;
map_cache_ready = false;
map_cache_surface = -1;
map_cache_camera = -1;
map_cache_scale = 1;
map_cache_max_size = 4096;
map_work_budget_us = 4000;
map_bake_item = 0;
map_bake_tile = 0;
map_bake_started = false;
map_content_bounds = [room_width, room_height, 0, 0];

capture_map = function()
{
    map_sprites = [];
    map_player = undefined;
    // Refresh the marker/sprite snapshot without invalidating prepared artwork.
    // A partially prepared cache also resumes where it stopped last time.
    with (all)
    {
        if (visible && sprite_index != -1 && id != other.id && object_index != o_Player)
            array_push(other.map_sprites, { depth: depth, tilemap: -1,
                sprite: sprite_index, frame: image_index, x: x, y: y,
                xs: image_xscale, ys: image_yscale, angle: image_angle,
                blend: image_blend, alpha: image_alpha });
    }
    if (instance_exists(o_Player)) map_player = [o_Player.x, o_Player.y];
};

map_rebuild = function()
{
    map_scan_started = false;
    map_scan_ready = false;
    map_cache_ready = false;
    map_bake_started = false;
    map_zoom = 1;
};

map_begin_scan = function()
{
    map_items = [];
    map_scan_layers = [];
    map_scan_layer = 0;
    map_scan_cell = 0;
    map_content_bounds = [room_width, room_height, 0, 0];
    var _layers = layer_get_all();
    for (var _i = 0; _i < array_length(_layers); ++_i)
    {
        var _layer = _layers[_i];
        var _tilemap = layer_tilemap_get_id(_layer);
        if (_tilemap == -1) continue;
        var _tileset = tilemap_get_tileset(_tilemap);
        if (_tileset == -1) continue;
        var _width = tilemap_get_width(_tilemap);
        var _height = tilemap_get_height(_tilemap);
        if (_width <= 0 || _height <= 0) continue;
        array_push(map_scan_layers, { depth: layer_get_depth(_layer), tilemap: _tilemap,
            tileset: _tileset, tiles: [], width: _width, height: _height,
            tile_width: tilemap_get_tile_width(_tilemap),
            tile_height: tilemap_get_tile_height(_tilemap),
            x: layer_get_x(_layer) + tilemap_get_x(_tilemap),
            y: layer_get_y(_layer) + tilemap_get_y(_tilemap),
            fit: string_pos("bg_", string_lower(layer_get_name(_layer))) != 1 });
    }
    map_scan_started = true;
};

map_update_scan = function()
{
    if (!map_scan_started) map_begin_scan();
    if (map_scan_ready) return;
    var _start = get_timer();
    var _processed = 0;
    while (map_scan_layer < array_length(map_scan_layers))
    {
        var _item = map_scan_layers[map_scan_layer];
        var _total = _item.width * _item.height;
        while (map_scan_cell < _total)
        {
            var _data = tilemap_get(_item.tilemap, map_scan_cell mod _item.width,
                floor(map_scan_cell / _item.width));
            if (tile_get_index(_data) != 0)
            {
                var _x = _item.x + (map_scan_cell mod _item.width) * _item.tile_width;
                var _y = _item.y + floor(map_scan_cell / _item.width) * _item.tile_height;
                array_push(_item.tiles, { data: _data, x: _x, y: _y });
                if (_item.fit)
                {
                    map_content_bounds[0] = min(map_content_bounds[0], _x);
                    map_content_bounds[1] = min(map_content_bounds[1], _y);
                    map_content_bounds[2] = max(map_content_bounds[2], _x + _item.tile_width);
                    map_content_bounds[3] = max(map_content_bounds[3], _y + _item.tile_height);
                }
            }
            ++map_scan_cell;
            if ((++_processed mod 256) == 0 && get_timer() - _start >= map_work_budget_us) return;
        }
        array_push(map_items, _item);
        ++map_scan_layer;
        map_scan_cell = 0;
    }
    for (var _i = 0; _i < array_length(map_sprites); ++_i)
        array_push(map_items, map_sprites[_i]);
    array_sort(map_items, function(_a, _b) { return sign(_b.depth - _a.depth); });
    var _b = map_content_bounds;
    if (_b[2] > _b[0] && _b[3] > _b[1])
    {
        if (!is_undefined(map_player))
        {
            _b[0] = min(_b[0], map_player[0]);
            _b[1] = min(_b[1], map_player[1]);
            _b[2] = max(_b[2], map_player[0]);
            _b[3] = max(_b[3], map_player[1]);
        }
        map_bounds = [max(0, _b[0] - map_fit_padding), max(0, _b[1] - map_fit_padding),
            min(room_width, _b[2] + map_fit_padding), min(room_height, _b[3] + map_fit_padding)];
    }
    else map_bounds = [0, 0, room_width, room_height];
    map_center_x = (map_bounds[0] + map_bounds[2]) * 0.5;
    map_center_y = (map_bounds[1] + map_bounds[3]) * 0.5;
    map_scan_ready = true;
    map_scan_layers = [];
};

// Retain the baked surface across menu opens; rebake retained data on surface loss.
map_bake_cache = function()
{
    if (!map_scan_ready || (map_cache_ready && surface_exists(map_cache_surface))) return;
    if (!surface_exists(map_cache_surface)) map_bake_started = false;
    var _world = matrix_get(matrix_world);
    var _view = matrix_get(matrix_view);
    var _projection = matrix_get(matrix_projection);
    if (!map_bake_started)
    {
        if (surface_exists(map_cache_surface)) surface_free(map_cache_surface);
        var _width = max(1, map_bounds[2] - map_bounds[0]);
        var _height = max(1, map_bounds[3] - map_bounds[1]);
        map_cache_scale = min(1, map_cache_max_size / max(_width, _height));
        var _sw = max(1, ceil(_width * map_cache_scale));
        var _sh = max(1, ceil(_height * map_cache_scale));
        map_cache_surface = surface_create(_sw, _sh);
        if (!surface_exists(map_cache_surface)) return;
        if (map_cache_camera == -1)
            map_cache_camera = camera_create_view(0, 0, _sw, _sh);
        else camera_set_view_size(map_cache_camera, _sw, _sh);
        surface_set_target(map_cache_surface);
        draw_clear_alpha(make_color_rgb(30, 36, 44), 1);
        surface_reset_target();
        map_bake_item = 0;
        map_bake_tile = 0;
        map_bake_started = true;
        map_cache_ready = false;
    }
    surface_set_target(map_cache_surface);
    camera_apply(map_cache_camera);
    matrix_set(matrix_world, matrix_build(-map_bounds[0] * map_cache_scale,
        -map_bounds[1] * map_cache_scale, 0, 0, 0, 0, map_cache_scale, map_cache_scale, 1));
    draw_set_color(c_white);
    draw_set_alpha(1);
    var _start = get_timer();
    var _processed = 0;
    var _yield = false;
    while (map_bake_item < array_length(map_items) && !_yield)
    {
        var _item = map_items[map_bake_item];
        if (_item.tilemap != -1)
        {
            while (map_bake_tile < array_length(_item.tiles))
            {
                var _tile = _item.tiles[map_bake_tile++];
                draw_tile(_item.tileset, _tile.data, 0, _tile.x, _tile.y);
                if ((++_processed mod 128) == 0 && get_timer() - _start >= map_work_budget_us)
                { _yield = true; break; }
            }
            if (_yield) break;
        }
        else
            draw_sprite_ext(_item.sprite, _item.frame, _item.x, _item.y,
                _item.xs, _item.ys, _item.angle, _item.blend, _item.alpha);
        ++map_bake_item;
        map_bake_tile = 0;
        if (get_timer() - _start >= map_work_budget_us) break;
    }
    surface_reset_target();
    matrix_set(matrix_world, _world);
    matrix_set(matrix_view, _view);
    matrix_set(matrix_projection, _projection);
    if (map_bake_item >= array_length(map_items)) map_cache_ready = true;
};

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
    capture_map();
    with (o_Player)
    {
        stop_movement_sfx();
        stop_electric_wires_sfx();
        stop_molten_lava_sfx();
        stop_gear_grinder_sfx();
        stop_ambush_alarm_sfx();
        stop_scrap_sfx();
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
    window_set_cursor(cr_default);
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
    map_open = false;
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
        case 2: return [12, 5, 6, 7, 8, 9, 99];
        case 3: return [20, 25, 21, 22, 23, 24, 99];
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
        case 12: return "Open level map / click to teleport";
		case 11: return "Freecam [F6]: " + (global.dev_freecam ? "ON" : "OFF");
        case 20: return "Spawn scout at captured cursor";
        case 21: return "Spawn drone at captured cursor";
        case 22: return "Spawn miniboss at captured cursor";
        case 23: return "Freeze enemy AI: " + (global.dev_freeze_enemies ? "ON" : "OFF");
        case 24: return "Clear all enemies";
        case 25: return "Spawn scout (mini) at captured cursor";
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
    if (_action == 12)
    {
        map_open = true;
        map_zoom = 1;
        map_center_x = (map_bounds[0] + map_bounds[2]) * 0.5;
        map_center_y = (map_bounds[1] + map_bounds[3]) * 0.5;
        map_mouse_x = device_mouse_x_to_gui(0);
        map_mouse_y = device_mouse_y_to_gui(0);
        return;
    }
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
            with (o_SeamlessTravel)
            {
                pending = undefined;
                transition_cooldown = 0;

                // A restart creates fresh fixtures; it is not a saved-room return.
                if (variable_instance_exists(id, "physics_visited_rooms"))
                {
                    var _key = room_get_name(room);
                    if (variable_struct_exists(physics_visited_rooms, _key))
                    {
                        variable_struct_remove(physics_visited_rooms, _key);
                    }
                }
            }
            room_persistent = false;
            room_restart();
            return;
        case 20: instance_create_depth(cursor_position[0], cursor_position[1], 0, oEnemy_Scout); break;
        case 21: instance_create_depth(cursor_position[0], cursor_position[1], 0, oDrone); break;
        case 22: instance_create_depth(cursor_position[0], cursor_position[1], 0, oEnemy_Breaker); break;
        case 25: instance_create_depth(cursor_position[0], cursor_position[1], 0, oEnemy_Scout_mini); break;
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
