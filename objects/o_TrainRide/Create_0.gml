// Place this instance at the cabin's TOP-LEFT corner in the tutorial.
depth = 500;
train_left = 6816;
train_roof = 2208;
train_right = 7392;
train_floor = 2400;
train_width = train_right - train_left;
train_height = train_floor - train_roof;

ride_started = false;
ride_elapsed = 0;
ride_duration = 12;
arrival_duration = 4;
arrived = false;
tram_sound = -1;
stop_tram_sfx = function()
{
    if (tram_sound != -1 && audio_is_playing(tram_sound))
    {
        audio_stop_sound(tram_sound);
    }
    tram_sound = -1;
};
scenery_max_speed = 220;
scenery_speed = 0;
scenery_distance = 0;
departure_enemies = [];
cruise_duration = max(0, ride_duration - arrival_duration);
total_travel_distance = scenery_max_speed * cruise_duration
    + scenery_max_speed * arrival_duration * 0.5;

camera_target_x = (train_left + train_right) * 0.5;
camera_target_y = train_floor;

// These layers must contain ART ONLY, painted at its final world position.
tunnel_a = layer_get_id("Tunnel_A");
tunnel_b = layer_get_id("Tunnel_B");
station_layer = layer_get_id("Station_Arrival");
station_layer_1 = layer_get_id("Station_Arrival_1");
station_layer_2 = layer_get_id("Station_Arrival_1_light");
departure_layer = layer_get_id("Station_Departure");
underwalkway_layer = layer_get_id("underwalkway");
fade2black_layer = layer_get_id("fade2black");
bgfar_layer = layer_get_id("BG_Far");
// Store each layer's room-editor offset so relocated artwork stays aligned.
tunnel_a_base_x = tunnel_a != -1 ? layer_get_x(tunnel_a) : 0;
tunnel_b_base_x = tunnel_b != -1 ? layer_get_x(tunnel_b) : 0;
station_base_x = station_layer != -1 ? layer_get_x(station_layer) : 0;
station_1_base_x = station_layer_1 != -1 ? layer_get_x(station_layer_1) : 0;
station_2_base_x = station_layer_2 != -1 ? layer_get_x(station_layer_2) : 0;
station_lights = [];
departure_base_x = departure_layer != -1 ? layer_get_x(departure_layer) : 0;
underwalkway_base_x = underwalkway_layer != -1 ? layer_get_x(underwalkway_layer) : 0;
fade2black_base_x = fade2black_layer != -1 ? layer_get_x(fade2black_layer) : 0;
bgfar_base_x = bgfar_layer != -1 ? layer_get_x(bgfar_layer) : 0;
tunnel_repeat_width = 3200;
tunnel_scroll = 0;

if (tunnel_a != -1) layer_x(tunnel_a, tunnel_a_base_x);
if (tunnel_b != -1) layer_x(tunnel_b, tunnel_b_base_x + tunnel_repeat_width);
if (station_layer != -1) layer_x(station_layer, station_base_x + total_travel_distance);
if (station_layer_1 != -1) layer_x(station_layer_1, station_1_base_x + total_travel_distance);

train_exit_door = noone;
train_entrance_door = noone;

boarding_requested = false;
entrance_open_distance = 110;

train_boarding_unlocked = function()
{
    if (instance_exists(oEnemy_Breaker)) return false;

    // An untriggered ambush must not count as an already-defeated boss.
    for (var _i = 0; _i < instance_number(o_DoorEnemySpawn); _i++)
    {
        var _spawn = instance_find(o_DoorEnemySpawn, _i);
        if (_spawn.enemy_object == oEnemy_Breaker) return false;
    }
    return true;
};

train_find_entrance = function()
{
    if (instance_exists(train_entrance_door))
    {
        return true;
    }

    var _door = instance_nearest(
        train_left,
        train_floor - 64,
        o_Door_UNB
    );

    if (!instance_exists(_door)) return false;

    if (point_distance(
        _door.x, _door.y,
        train_left, train_floor - 64
    ) > 48)
    {
        return false;
    }

    train_entrance_door = _door;
    train_entrance_door.boarding_lock_owner = id;
    return true;
};

begin_ride = function(_player)
{
    if (ride_started
    || !train_boarding_unlocked()
    || !instance_exists(_player)
    || _player.pHP <= 0)
    {
        return false;
    }

    // The player must be safely inside the cabin.
    if (_player.x < train_left + 80
    || _player.x > train_right - 80
    || _player.y < train_roof + 64
    || _player.y > train_floor + 8)
    {
        return false;
    }

    if (!train_find_entrance()) return false;

    // Find only this cabin's marked right exit.
    train_exit_door = noone;

    var _exit_x = train_right - 32;
    var _exit_y = train_floor - 64;

    for (var _i = 0; _i < instance_number(o_Door_UNB); _i++)
    {
        var _door = instance_find(o_Door_UNB, _i);

        if (!variable_instance_exists(_door, "train_exit"))
        {
            continue;
        }

        if (!_door.train_exit) continue;

        if (point_distance(
            _door.x, _door.y,
            _exit_x, _exit_y
        ) <= 48)
        {
            train_exit_door = _door;
            break;
        }
    }

    if (!instance_exists(train_exit_door)) return false;
    if (train_exit_door.door_state != 0) return false;

    boarding_requested = true;

    // If still opening, wait until fully open before closing.
    if (train_entrance_door.door_state == 2)
    {
        train_entrance_door.door_close();
    }

    // Depart only after the closing animation finishes.
    if (train_entrance_door.door_state != 0)
    {
        return false;
    }

    if (bgfar_layer != -1) bgfar_base_x = layer_get_x(bgfar_layer);
    ride_started = true;
    tram_sound = audio_play_sound(sfxTram, 0, true, 0.65);
    ride_elapsed = 0;
    scenery_speed = scenery_max_speed;
	
	// Enemies outside the cabin belong to the departing scenery.
    departure_enemies = [];
    for (var _enemy_i = 0; _enemy_i < instance_number(oEnemyParent); _enemy_i++)
    {
        var _enemy = instance_find(oEnemyParent, _enemy_i);
        var _cx = (_enemy.bbox_left + _enemy.bbox_right) * 0.5;
        var _cy = (_enemy.bbox_top + _enemy.bbox_bottom) * 0.5;

        var _in_cabin = _cx >= train_left && _cx <= train_right
            && _cy >= train_roof && _cy <= train_floor;

        // Leave enemies in the destination station alone.
        if (_in_cabin || _cx > train_right) continue;

        array_push(departure_enemies, {
            enemy: _enemy,
            start_x: _enemy.x,
            start_y: _enemy.y
        });

        _enemy.train_departing = true;
        if (variable_instance_exists(_enemy, "drone_ready"))
            _enemy.drone_ready = false;
        if (variable_instance_exists(_enemy, "drone_fire_state"))
            _enemy.drone_fire_state = 0;
        with (_enemy)
        {
            path_end();
            speed = 0;
        }
    }

    return true;
};
