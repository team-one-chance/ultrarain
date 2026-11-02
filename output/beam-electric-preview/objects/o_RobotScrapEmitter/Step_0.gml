// Wait until Step so every room instance has completed its Create event.
if (!drop_bounds_ready)
{
    if (drop_auto_bounds) refresh_drop_bounds();
    else drop_bounds_ready = true;
}

var _dt = max(0, (variable_global_exists("dev_delta_time")
    ? global.dev_delta_time : delta_time) / 1000000);

if (pending_burst > 0)
{
    burst_timer -= _dt;
    if (burst_timer <= 0)
    {
        spawn_hatch();
        pending_burst--;
        burst_timer = random_range(drop_burst_min_delay, drop_burst_max_delay);
    }
}

drop_timer -= _dt;
if (drop_timer <= 0)
{
    var _spawned = spawn_hatch();
    drop_timer = random_range(drop_interval_min, drop_interval_max);
    if (random(1) < drop_quiet_chance)
        drop_timer += random_range(drop_quiet_min, drop_quiet_max);

    if (_spawned && pending_burst == 0 && random(1) < drop_burst_chance)
    {
        pending_burst = irandom_range(1, 2);
        burst_timer = random_range(drop_burst_min_delay, drop_burst_max_delay);
    }
}
