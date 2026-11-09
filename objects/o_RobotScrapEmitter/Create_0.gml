image_speed = 0;
// Seed once per run, rather than repeating the IDE's deterministic sequence.
if (!variable_global_exists("scrap_rng_started"))
{
    randomize();
    global.scrap_rng_started = true;
}

drop_min_y = 544;
drop_max_y = 545;
drop_interval_min = 0.9; // Seconds between drops; larger values thin out the scrap.
drop_interval_max = 1.2; // Seconds; keep a steady hazard instead of dense waves.
drop_quiet_chance = 0; // Probability per drop; no long safe windows between waves.
drop_quiet_min = 3.0;
drop_quiet_max = 4.8;
drop_burst_chance = 0; // Probability per drop; disable extra drops stacked on the regular cadence.
drop_burst_min_delay = 0.45;
drop_burst_max_delay = 0.95;
drop_timer = random_range(1.25, 1.8);
pending_burst = 0;
burst_timer = 0;
max_falling_bodies = 24;
drop_min_gap = 80;
drop_min_x = 4416;
drop_max_x = 5120;
drop_auto_bounds = true;
drop_bounds_ready = false;

refresh_drop_bounds = function()
{
    var _left = room_width;
    var _right = 0;
    var _count = 0;
    var _types = [o_GrinderLeft, o_GrinderRight];
    for (var _t = 0; _t < array_length(_types); _t++)
    {
        for (var _i = 0; _i < instance_number(_types[_t]); _i++)
        {
            var _gear = instance_find(_types[_t], _i);
            // Keep an emitter local if another grinder row exists elsewhere.
            if (abs((_gear.bbox_left + _gear.bbox_right) * 0.5 - x) > 1600) continue;
            _left = min(_left, _gear.bbox_left);
            _right = max(_right, _gear.bbox_right);
            _count++;
        }
    }
    if (_count > 0)
    {
        drop_min_x = _left + 36;
        drop_max_x = max(drop_min_x, _right - 36);
    }
    drop_bounds_ready = true;
};

spawn_hatch = function()
{
    if (instance_number(o_FallingRobotScrap) + instance_number(o_RobotDropHatch)
        >= max_falling_bodies) return false;

    for (var _attempt = 0; _attempt < 12; _attempt++)
    {
        var _spawn_x = random_range(drop_min_x, drop_max_x);
        var _clear = true;
        for (var _i = 0; _i < instance_number(o_RobotDropHatch); _i++)
        {
            var _hatch = instance_find(o_RobotDropHatch, _i);
            if (_hatch.drop_emitter == id && abs(_hatch.x - _spawn_x) < drop_min_gap)
            {
                _clear = false;
                break;
            }
        }
        if (!_clear) continue;

        var _hatch = instance_create_depth(_spawn_x,
            random_range(drop_min_y, drop_max_y), depth - 2, o_RobotDropHatch);
        _hatch.drop_emitter = id;
        return true;
    }
    return false;
};

release_robot = function(_spawn_x, _opening_y)
{
    if (instance_number(o_FallingRobotScrap) >= max_falling_bodies) return noone;
    var _body = instance_create_depth(_spawn_x, _opening_y,
        depth = -1, o_FallingRobotScrap);
    _body.scrap_emitter = id;
    _body.scrap_release_y = _opening_y;
    _body.y = _opening_y - 24 * _body.scrap_size;
    _body.scrap_release_angle = _body.scrap_draw_angle;
    _body.scrap_draw_angle = 0;
    _body.scrap_emerged = false;
    _body.scrap_before_x = _body.x;
    _body.scrap_before_y = _body.y;
    return _body;
};
