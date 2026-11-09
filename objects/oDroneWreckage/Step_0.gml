var _dt = clamp((variable_global_exists("dev_delta_time")
    ? global.dev_delta_time : delta_time) / 1000000, 0, 0.05);
if (_dt <= 0) exit;

for (var _i = array_length(wreck_parts) - 1; _i >= 0; _i--)
{
    var _part = wreck_parts[_i];
    var _w = _part.width * abs(wreck_scale_x) * 0.5;
    var _h = _part.height * abs(wreck_scale_y) * 0.5;
    var _hw = abs(dcos(_part.angle)) * _w + abs(dsin(_part.angle)) * _h;
    var _hh = abs(dsin(_part.angle)) * _w + abs(dcos(_part.angle)) * _h;

    if (_part.resting)
    {
        // Resume falling if a supporting door/platform disappears.
        if (wreck_blocked(_part.px, _part.py + 1, _hw, _hh)) continue;
        _part.resting = false;
    }

    var _angle = _part.angle + _part.spin * _dt;
    var _next_hw = abs(dcos(_angle)) * _w + abs(dsin(_angle)) * _h;
    var _next_hh = abs(dsin(_angle)) * _w + abs(dcos(_angle)) * _h;
    if (!wreck_blocked(_part.px, _part.py, _next_hw, _next_hh))
    {
        _part.angle = _angle;
        _hw = _next_hw;
        _hh = _next_hh;
    }

    _part.vy = min(600, _part.vy + wreck_gravity * _dt);
    var _dx = _part.vx * _dt;
    var _dy = _part.vy * _dt;
    // Sweep in steps of at most one pixel to catch thin floors and walls.
    var _steps = max(1, ceil(max(abs(_dx), abs(_dy))));
    var _step_x = _dx / _steps;
    var _step_y = _dy / _steps;
    repeat (_steps)
    {
        if (!wreck_blocked(_part.px + _step_x, _part.py, _hw, _hh))
        {
            _part.px += _step_x;
        }
        else
        {
            _part.vx *= -0.2;
            _part.spin *= 0.5;
            _step_x = 0;
        }
        if (!wreck_blocked(_part.px, _part.py + _step_y, _hw, _hh))
        {
            _part.py += _step_y;
        }
        else
        {
            if (_step_y > 0)
            {
                if (_part.vy > 60 && _part.bounces < wreck_bounce_limit)
                {
                    _part.vy *= -0.2;
                    _part.vx *= 0.6;
                    _part.spin *= 0.35;
                    _part.bounces++;
                }
                else
                {
                    _part.vx = 0;
                    _part.vy = 0;
                    _part.spin = 0;
                    _part.resting = true;
                    break;
                }
            }
            else
            {
                _part.vy = abs(_part.vy) * 0.15;
            }
            _step_y = 0;
        }
    }

    // Only discard pieces that fall outside the room, never settled remains.
    if (_part.py > room_height + 64 || _part.px < -64 || _part.px > room_width + 64)
    {
        array_delete(wreck_parts, _i, 1);
    }
}
if (array_length(wreck_parts) == 0) instance_destroy();
