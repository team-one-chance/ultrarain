if (timer_running)
{
    elapsed_time += (
        variable_global_exists("dev_delta_time")
        ? global.dev_delta_time
        : delta_time
    ) / 1000000;
}

if (!timer_running) exit;

var _player = instance_find(o_Player, 0);

if (!instance_exists(_player)) exit;

var _train = instance_nearest(
    _player.x, _player.y, o_TrainRide
);

if (!instance_exists(_train)) exit;

// begin_ride checks whether the player is inside the cabin.
// No collision with the timer's sprite is required.
if (_train.begin_ride(_player))
{
    timer_running = false;
    global.demo_finish_time = elapsed_time;
}