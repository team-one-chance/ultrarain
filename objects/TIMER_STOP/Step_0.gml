if (timer_running)
{
    elapsed_time += (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) / 1000000;
}

// Touching the finish boards the train.
if (timer_running && place_meeting(x, y, o_Player))
{
    var _player = instance_nearest(x, y, o_Player);

    if (instance_exists(_player))
    {
        timer_running = false;
        global.demo_finish_time = elapsed_time;

        demo_save_player(_player);
        room_goto(LE_TRAIN);
        exit;
    }
}