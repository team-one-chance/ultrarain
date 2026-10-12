// Place this instance at the cabin's TOP-LEFT corner in the tutorial.
depth = 550;
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
scenery_max_speed = 220;
scenery_speed = 0;
scenery_distance = 0;
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
departure_layer = layer_get_id("Station_Departure");
// Store each layer's room-editor offset so relocated artwork stays aligned.
tunnel_a_base_x = tunnel_a != -1 ? layer_get_x(tunnel_a) : 0;
tunnel_b_base_x = tunnel_b != -1 ? layer_get_x(tunnel_b) : 0;
station_base_x = station_layer != -1 ? layer_get_x(station_layer) : 0;
station_1_base_x = station_layer_1 != -1 ? layer_get_x(station_layer_1) : 0;
departure_base_x = departure_layer != -1 ? layer_get_x(departure_layer) : 0;
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
    return true;
};

begin_ride = function(_player)
{
    if (ride_started
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

    ride_started = true;
    ride_elapsed = 0;
    scenery_speed = scenery_max_speed;

    return true;
};