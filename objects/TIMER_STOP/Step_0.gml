// Count upward
if (timer_running)
{
    elapsed_time += delta_time / 1000000;
}


// Player touched finish object
if (timer_running
&& place_meeting(x, y, o_Player))
{
    timer_running = false;
}