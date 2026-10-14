event_inherited();

// RIG CONFIG: pixels, sprite-local pivots, and seconds. x/y use the
// body's authored top-left origin; place the body above the floor.
basher_config = {
    upper_length: 23,
    lower_length: 26,
    upper_pivot: [6.5, 7.5],
    upper_end: [11, 27],
    lower_pivot: [8.5, 6.5],
    lower_end: [8.5, 32],
    foot_pivot: [16, 7],
    foot_sole: 6,
    body_pivot: [36, 14],
    // Low body; the hips align with the body's circular joint sockets.
    standing_height: 36,
    stride_distance: 8,
    step_lead: 6,
    step_height: 6,
    step_duration: 0.16,
    walk_speed: 48,
    stop_distance: 100,
    ground_probe_up: 20,
    ground_probe_down: 160,
    ground_angle_span: 6,
    far_colour: make_color_rgb(150, 150, 160),
    // far rear, far front, near rear, near front.
    // Each knee sign stays fixed, including when walking backwards.
    legs: [
        { hip: [28, 24], home_x: 8,  knee_sign: 1, pair: 0, near: false },
        { hip: [48, 24], home_x: 28, knee_sign: 1, pair: 1, near: false },
        { hip: [28, 24], home_x: 10, knee_sign: 1, pair: 1, near: true  },
        { hip: [48, 24], home_x: 30, knee_sign: 1, pair: 0, near: true  }
    ]
};

ehp_max = 150;
ehp = ehp_max;
hit_duration = 0.15;
hit_timer = 0;
image_speed = 0;
// The first pass has no attack or aerial slam animation.
slam_enabled = false;
basher_ready = false;
basher_pair = 0;
basher_active_pair = -1;
basher_step_time = 0;
basher_legs = [];

// Find the FIRST occupied pixel, including thin platforms. All project
// o_Block descendants participate through GameMaker's parent collisions.
basher_ground = function(_px, _around_y)
{
    var _cfg = basher_config;
    var _start = floor(_around_y - _cfg.ground_probe_up);
    var _end = ceil(_around_y + _cfg.ground_probe_down);
    if (collision_point(_px, _start, o_Block, false, true) != noone) return undefined;
    if (collision_line(_px, _start, _px, _end, o_Block, false, true) == noone) return undefined;
    for (var _py = _start + 1; _py <= _end; ++_py)
    {
        if (collision_point(_px, _py, o_Block, false, true) != noone) return _py;
    }
    return undefined;
};

basher_ground_angle = function(_px, _ground_y)
{
    var _span = max(1, basher_config.ground_angle_span);
    var _left = basher_ground(_px - _span, _ground_y);
    var _right = basher_ground(_px + _span, _ground_y);
    if (is_undefined(_left) || is_undefined(_right)) return 0;
    if (abs(_left - _right) > _span * 2) return 0;
    return point_direction(_px - _span, _left, _px + _span, _right);
};

// Custom pivots leave the source sprite origins untouched. A single
// constant scale maps the authored joint centres to the configured length.
basher_draw_part = function(_spr, _pivot, _px, _py, _angle, _scale, _colour)
{
    var _ox = (sprite_get_xoffset(_spr) - _pivot[0]) * _scale;
    var _oy = (sprite_get_yoffset(_spr) - _pivot[1]) * _scale;
    draw_sprite_ext(_spr, 0,
        _px + _ox * dcos(_angle) + _oy * dsin(_angle),
        _py - _ox * dsin(_angle) + _oy * dcos(_angle),
        _scale, _scale, _angle, _colour, image_alpha);
};

basher_draw_leg = function(_index)
{
    var _cfg = basher_config;
    var _def = _cfg.legs[_index];
    var _leg = basher_legs[_index];
    var _hx = x + _def.hip[0];
    var _hy = y + _def.hip[1];
    var _a = max(0.01, _cfg.upper_length);
    var _b = max(0.01, _cfg.lower_length);
    var _dx = _leg.foot_x - _hx;
    var _dy = _leg.foot_y - _hy;
    var _raw_d = max(0.0001, sqrt(_dx * _dx + _dy * _dy));
    // Singular/unreachable targets have a safe fixed-length solution.
    var _d = clamp(_raw_d, abs(_a - _b) + 0.0001, _a + _b - 0.0001);
    var _along = (_a * _a - _b * _b + _d * _d) / (2 * _d);
    var _height = sqrt(max(0, _a * _a - _along * _along));
    var _ux = _dx / _raw_d;
    var _uy = _dy / _raw_d;
    var _kx = _hx + _ux * _along - _uy * _height * _def.knee_sign;
    var _ky = _hy + _uy * _along + _ux * _height * _def.knee_sign;
    var _ax = _hx + _ux * _d;
    var _ay = _hy + _uy * _d;
    var _colour = _def.near ? c_white : _cfg.far_colour;
    var _upper_axis = point_direction(_cfg.upper_pivot[0], _cfg.upper_pivot[1], _cfg.upper_end[0], _cfg.upper_end[1]);
    var _lower_axis = point_direction(_cfg.lower_pivot[0], _cfg.lower_pivot[1], _cfg.lower_end[0], _cfg.lower_end[1]);
    basher_draw_part(sBasherLegUpper, _cfg.upper_pivot, _hx, _hy,
        point_direction(_hx, _hy, _kx, _ky) - _upper_axis,
        _a / max(0.01, point_distance(_cfg.upper_pivot[0], _cfg.upper_pivot[1], _cfg.upper_end[0], _cfg.upper_end[1])), _colour);
    basher_draw_part(sBasherLegLower, _cfg.lower_pivot, _kx, _ky,
        point_direction(_kx, _ky, _ax, _ay) - _lower_axis,
        _b / max(0.01, point_distance(_cfg.lower_pivot[0], _cfg.lower_pivot[1], _cfg.lower_end[0], _cfg.lower_end[1])), _colour);
    basher_draw_part(sBasherSteppy, _cfg.foot_pivot, _ax, _ay, _leg.foot_angle, 1, _colour);
};
