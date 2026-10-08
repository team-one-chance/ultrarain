var _player = instance_find(o_Player, 0);

if (!instance_exists(_player)) exit;

var _dt = (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) / 1000000;

ride_elapsed = min(
    ride_duration,
    ride_elapsed + _dt
);

if (ride_elapsed < cruise_duration)
{
    scenery_speed = scenery_max_speed;
    scenery_distance = scenery_max_speed * ride_elapsed;
}
else
{
    var _braking_time = clamp(
        ride_elapsed - cruise_duration,
        0,
        arrival_duration
    );

    var _progress = _braking_time / arrival_duration;

    scenery_speed = scenery_max_speed * (1 - _progress);

    // Integrated distance prevents scenery jumping as speed changes.
    scenery_distance =
        scenery_max_speed * cruise_duration
        + scenery_max_speed * (
            _braking_time
            - sqr(_braking_time) / (2 * arrival_duration)
        );
}

tunnel_scroll =
    scenery_distance mod tunnel_repeat_width;

if (tunnel_a != -1)
{
    layer_x(tunnel_a, -tunnel_scroll);
}

if (tunnel_b != -1)
{
    layer_x(
        tunnel_b,
        tunnel_repeat_width - tunnel_scroll
    );
}

if (station_layer != -1)
{
    layer_x(
        station_layer,
        max(0, total_travel_distance - scenery_distance)
    );
}

// Open the marked exit once, after stopping.
if (!arrived && ride_elapsed >= ride_duration)
{
    arrived = true;
    scenery_speed = 0;

    with (o_Door_UNB)
    {
        if (variable_instance_exists(id, "train_exit"))
        {
            if (train_exit)
            {
                door_open();
            }
        }
    }

    // Allow the camera to follow the player onto the platform.
    if (!instance_exists(o_CAMERA))
    {
        instance_create_depth(0, 0, -100, o_CAMERA);
    }
}