// Imported body and four legs; offsets are relative to the scout's feet.
// Atlas rectangle followed by the piece's local center offset.
wreck_sprite = sScoutWreckage;
wreck_frame = 0;
wreck_source_width = 49;
wreck_source_height = 18;
wreck_cuts = [
    [0, 0, 17, 18, 0, -16],
    [17, 0, 8, 15, -8, -7.5],
    [25, 0, 8, 15, -4, -7.5],
    [33, 0, 8, 15, 8, -7.5],
    [41, 0, 8, 15, 4, -7.5]
];
wreck_bounce_limit = 0;
event_inherited();

// Scout breakup tuning: the heavier body stays close; legs scatter independently.
wreck_body_speed_x = 45;
wreck_leg_speed_x_min = 35;
wreck_leg_speed_x_max = 95;
wreck_body_up_min = 65;
wreck_body_up_max = 105;
wreck_leg_up_min = 100;
wreck_leg_up_max = 155;
wreck_spin_min = 180;
wreck_spin_max = 420;
wreck_spawn_clearance = 2;

for (var _i = array_length(wreck_parts) - 1; _i >= 0; _i--)
{
    var _part = wreck_parts[_i];
    var _body = _i == 0;
    _part.angle = wreck_angle + (_body ? random_range(-25, 25) : random(360));
    _part.vx = _body ? random_range(-wreck_body_speed_x, wreck_body_speed_x)
        : choose(-1, 1) * random_range(wreck_leg_speed_x_min, wreck_leg_speed_x_max);
    _part.vy = _body ? -random_range(wreck_body_up_min, wreck_body_up_max)
        : -random_range(wreck_leg_up_min, wreck_leg_up_max);
    _part.spin = choose(-1, 1) * random_range(wreck_spin_min, wreck_spin_max) * (_body ? 0.5 : 1);

    // The source legs touch the scout's feet. Whole-pixel collision rounding
    // otherwise starts them inside the floor and cancels their launch impulse.
    // Clear the randomized rotated bounds before the first movement step.
    var _w = _part.width * abs(wreck_scale_x) * 0.5;
    var _h = _part.height * abs(wreck_scale_y) * 0.5;
    var _hw = abs(dcos(_part.angle)) * _w + abs(dsin(_part.angle)) * _h;
    var _hh = abs(dsin(_part.angle)) * _w + abs(dcos(_part.angle)) * _h;
    var _spawn_y = _part.py;
    var _escape = ceil((_w + _h) * 2) + wreck_spawn_clearance;
    var _clear = false;
    for (var _lift = 0; _lift <= _escape; _lift++)
    {
        var _py = _spawn_y - _lift;
        if (wreck_blocked(_part.px, _py, _hw + wreck_spawn_clearance,
            _hh + wreck_spawn_clearance)) continue;
        _part.py = _py;
        _clear = true;
        break;
    }
    // A piece fully embedded in room geometry has no safe launch position.
    if (!_clear) array_delete(wreck_parts, _i, 1);
}
