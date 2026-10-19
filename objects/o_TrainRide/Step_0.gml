if (!ride_started)
{
    var _boarding_player = instance_find(o_Player, 0);

    if (!instance_exists(_boarding_player)) exit;
    if (!train_find_entrance()) exit;

    if (!train_boarding_unlocked())
    {
        boarding_requested = false;
        exit;
    }

    var _inside =
        _boarding_player.x >= train_left + 80
        && _boarding_player.x <= train_right - 80
        && _boarding_player.y >= train_roof + 64
        && _boarding_player.y <= train_floor + 8;

    if (_inside)
    {
        boarding_requested = true;

        // Request closing directly, without waiting for the timer.
        if (train_entrance_door.door_state == 2)
        {
            train_entrance_door.door_close();
        }

        // Wait for the entrance to finish closing.
        if (train_entrance_door.door_state == 0)
        {
            if (begin_ride(_boarding_player))
            {
                with (TIMER_STOP)
                {
                    timer_running = false;
                    global.demo_finish_time = elapsed_time;
                }
            }
        }
    }
    else
    {
        boarding_requested = false;

        var _near = point_distance(
            _boarding_player.x,
            _boarding_player.y - 32,
            train_entrance_door.x + 16,
            train_entrance_door.y + 32
        ) <= entrance_open_distance;

        if (_near)
        {
            train_entrance_door.door_open();
        }
    }

    exit;
}

if (arrived)
{
    stop_tram_sfx();
    exit;
}
var _player = instance_find(o_Player, 0);
if (!instance_exists(_player))
{
    stop_tram_sfx();
    exit;
}
var _dt = max(0, (variable_global_exists("dev_delta_time")
    ? global.dev_delta_time : delta_time) / 1000000);
ride_elapsed = min(ride_duration, ride_elapsed + _dt);

if (ride_elapsed < cruise_duration)
{
    scenery_speed = scenery_max_speed;
    scenery_distance = scenery_max_speed * ride_elapsed;
}
else
{
    var _braking_time = clamp(ride_elapsed - cruise_duration, 0, arrival_duration);
    var _progress = _braking_time / arrival_duration;
    scenery_speed = scenery_max_speed * (1 - _progress);
    scenery_distance = scenery_max_speed * cruise_duration
        + scenery_max_speed * (_braking_time - sqr(_braking_time) / (2 * arrival_duration));
}

if (tram_sound == -1 || !audio_is_playing(tram_sound))
{
    tram_sound = audio_play_sound(sfxTram, 0, true, 0);
}
audio_sound_gain(tram_sound, clamp(scenery_speed / max(1, scenery_max_speed), 0, 1) * 0.65, 80);

tunnel_scroll = scenery_distance mod tunnel_repeat_width;
if (tunnel_a != -1) layer_x(tunnel_a, tunnel_a_base_x - tunnel_scroll);
if (tunnel_b != -1) layer_x(tunnel_b, tunnel_b_base_x + tunnel_repeat_width - tunnel_scroll);
if (departure_layer != -1) layer_x(departure_layer, departure_base_x - scenery_distance);
if (underwalkway_layer != -1) layer_x(underwalkway_layer, underwalkway_base_x - scenery_distance);
if (fade2black_layer != -1) layer_x(fade2black_layer, fade2black_base_x - scenery_distance);
if (bgfar_layer != -1) layer_x(bgfar_layer, bgfar_base_x - scenery_distance);
if (station_layer != -1)
    layer_x(station_layer, station_base_x + max(0, total_travel_distance - scenery_distance));
if (station_layer_1 != -1)
    layer_x(station_layer_1, station_1_base_x + max(0, total_travel_distance - scenery_distance));
var _light_offset = max(
    0,
    total_travel_distance - scenery_distance
);

for (var _i = 0; _i < array_length(station_lights); _i++)
{
    var _entry = station_lights[_i];

    if (instance_exists(_entry.instance))
    {
        _entry.instance.x = _entry.home_x + _light_offset;
    }
}
	

if (ride_elapsed >= ride_duration)
{
    arrived = true;
    stop_tram_sfx();
    scenery_speed = 0;
    if (instance_exists(train_exit_door)) train_exit_door.door_open();
}
