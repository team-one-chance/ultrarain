event_inherited();

// RIG CONFIG: pixels, sprite-local pivots, and seconds. x/y use the
// body's authored top-left origin; place the body above the floor.
basher_config = {
    leg_scale: 0.7, // Uniform size of upper legs, lower legs, and feet.
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
        { hip: [48, 24], home_x: 28, knee_sign: -1, pair: 1, near: false },
        { hip: [28, 24], home_x: 10, knee_sign: 1, pair: 1, near: true  },
        { hip: [48, 24], home_x: 30, knee_sign: -1, pair: 0, near: true  }
    ]
};

basher_base_config = variable_clone(basher_config);

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
basher_step_pause_remaining = 0;
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

// Project the requested contact into this leg's reachable ground interval.
// Recheck the actual floor after each projection, including on uneven ground.
basher_foothold = function(_index, _wanted_x, _body_x, _body_y)
{
    var _cfg = basher_config;
    var _hip = _cfg.legs[_index].hip;
    var _hx = _body_x + _hip[0];
    var _hy = _body_y + _hip[1];
    var _margin = min(1, min(_cfg.upper_length, _cfg.lower_length) * 0.05);
    var _outer = _cfg.upper_length + _cfg.lower_length - _margin - 0.1;
    var _inner = abs(_cfg.upper_length - _cfg.lower_length) + _margin + 0.1;
    var _tx = clamp(_wanted_x, _hx - _outer, _hx + _outer);
    var _side = sign(_wanted_x - _hx);
    if (_side == 0) _side = -1;
    for (var _pass = 0; _pass < 4; ++_pass)
    {
        var _ground = basher_ground(_tx, _body_y + _cfg.standing_height);
        if (is_undefined(_ground)) return undefined;
        var _angle = basher_ground_angle(_tx, _ground);
        var _ty = _ground - _cfg.foot_sole * dcos(_angle);
        var _dy = _ty - _hy;
        if (abs(_dy) >= _outer) return undefined;
        var _max_x = sqrt(max(0, _outer * _outer - _dy * _dy));
        var _min_x = sqrt(max(0, _inner * _inner - _dy * _dy));
        var _dx = _tx - _hx;
        var _distance = point_distance(_hx, _hy, _tx, _ty);
        if (_distance >= _inner - 0.001 && _distance <= _outer + 0.001)
            return { tx: _tx, ty: _ty, angle: _angle };
        _tx = _hx + _side * clamp(abs(_dx), _min_x, _max_x);
    }
    return undefined;
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
    basher_draw_part(sBasherSteppy, _cfg.foot_pivot, _ax, _ay, _leg.foot_angle, _cfg.foot_scale, _colour);
};

basher_draw_rig = function()
{
    if (basher_ready) { basher_draw_leg(0); basher_draw_leg(1); }
    var _scale = basher_config.body_scale;
    draw_sprite_ext(sBasherBody, 0, x, y, _scale, _scale, 0, image_blend, image_alpha);
    if (basher_ready) { basher_draw_leg(2); basher_draw_leg(3); }
};

// One schema drives defaults, sliders, loading, and exported values.
basher_controls = [
    { key: "body_scale", label: "Body size", page: 0, lo: 0.25, hi: 1.5, tick: 0.01, value: 1 },
    { key: "leg_scale", label: "All legs size", page: 0, lo: 0.2, hi: 1.5, tick: 0.01, value: 0.7 },
    { key: "upper_length", label: "Upper leg length", page: 0, lo: 6, hi: 45, tick: 0.5, value: 23 },
    { key: "lower_length", label: "Lower leg length", page: 0, lo: 6, hi: 45, tick: 0.5, value: 26 },
    { key: "foot_scale", label: "Foot size", page: 0, lo: 0.3, hi: 1.5, tick: 0.01, value: 1 },
    { key: "body_height", label: "Body height offset", page: 0, lo: -16, hi: 32, tick: 0.5, value: 0 },
    { key: "foot_reach", label: "Foot reach", page: 0, lo: 0.3, hi: 1.7, tick: 0.01, value: 1 },
    { key: "foot_spacing", label: "Foot spacing", page: 0, lo: 0.3, hi: 1.8, tick: 0.01, value: 1 },
    { key: "foot_shift", label: "Feet left / right", page: 0, lo: -20, hi: 20, tick: 0.5, value: 0 },
    { key: "walk_speed", label: "Walking speed", page: 1, lo: 0, hi: 360, tick: 1, value: 48 },
    { key: "stride_distance", label: "Stride distance", page: 1, lo: 2, hi: 120, tick: 0.5, value: 8 },
    { key: "step_lead", label: "Step lead", page: 1, lo: 0, hi: 120, tick: 0.5, value: 6 },
    { key: "reach_anticipation", label: "Early reach trigger (0 = off)", page: 1, lo: 0, hi: 1, tick: 0.01, value: 1 },
    { key: "step_height", label: "Step height", page: 1, lo: 0, hi: 20, tick: 0.5, value: 6 },
    { key: "step_duration", label: "Step duration (seconds)", page: 1, lo: 0.06, hi: 0.6, tick: 0.01, value: 0.16 },
    { key: "step_pause", label: "Pause between steps (seconds)", page: 1, lo: 0, hi: 0.8, tick: 0.01, value: 0 },
    { key: "step_arc", label: "Arc shape (wide / peaked)", page: 1, lo: 0.5, hi: 3, tick: 0.05, value: 1 },
    { key: "step_smoothing", label: "Step smoothing", page: 1, lo: 0, hi: 1, tick: 0.01, value: 1 },
    { key: "front_lift", label: "Front foot lift multiplier", page: 1, lo: 0, hi: 2, tick: 0.05, value: 1 },
    { key: "rear_lift", label: "Rear foot lift multiplier", page: 1, lo: 0, hi: 2, tick: 0.05, value: 1 },
    { key: "body_wait_for_legs", label: "Body waits for legs", page: 1, lo: 0, hi: 1, tick: 1, value: 1, toggle: true },
    { key: "rear_hip_x", label: "Rear hip X", page: 2, lo: 10, hi: 45, tick: 0.5, value: 28 },
    { key: "front_hip_x", label: "Front hip X", page: 2, lo: 25, hi: 65, tick: 0.5, value: 48 },
    { key: "hip_y", label: "Hip Y", page: 2, lo: 0, hi: 28, tick: 0.5, value: 24 },
    { key: "near_hip_y", label: "Near hip Y offset", page: 2, lo: -8, hi: 8, tick: 0.5, value: 0 },
    { key: "near_foot_offset", label: "Near foot separation", page: 2, lo: 0, hi: 10, tick: 0.5, value: 2 },
    { key: "front_knee_flip", label: "Front knee flip (0 / 1)", page: 2, lo: 0, hi: 1, tick: 1, value: 1 },
    { key: "rear_knee_flip", label: "Rear knee flip (0 / 1)", page: 2, lo: 0, hi: 1, tick: 1, value: 0 },
    { key: "upper_pivot_x", label: "Upper pivot X", page: 3, lo: 0, hi: 18, tick: 0.5, value: 6.5 },
    { key: "upper_pivot_y", label: "Upper pivot Y", page: 3, lo: 0, hi: 32, tick: 0.5, value: 7.5 },
    { key: "upper_end_x", label: "Upper end X", page: 3, lo: 0, hi: 18, tick: 0.5, value: 11 },
    { key: "upper_end_y", label: "Upper end Y", page: 3, lo: 0, hi: 32, tick: 0.5, value: 27 },
    { key: "lower_pivot_x", label: "Lower pivot X", page: 3, lo: 0, hi: 14, tick: 0.5, value: 8.5 },
    { key: "lower_pivot_y", label: "Lower pivot Y", page: 3, lo: 0, hi: 36, tick: 0.5, value: 6.5 },
    { key: "lower_end_x", label: "Lower end X", page: 3, lo: 0, hi: 14, tick: 0.5, value: 8.5 },
    { key: "lower_end_y", label: "Lower end Y", page: 3, lo: 0, hi: 36, tick: 0.5, value: 32 },
    { key: "foot_pivot_x", label: "Foot pivot X", page: 3, lo: 0, hi: 32, tick: 0.5, value: 16 },
    { key: "foot_pivot_y", label: "Foot pivot Y", page: 3, lo: 0, hi: 14, tick: 0.5, value: 7 }
];

if (!variable_global_exists("basher_tuning"))
{
    global.basher_tuning = {};
    for (var _i = 0; _i < array_length(basher_controls); ++_i)
    {
        var _control = basher_controls[_i];
        variable_struct_set(global.basher_tuning, _control.key, _control.value);
    }
    if (file_exists("basher_tuning.json"))
    {
        var _file = file_text_open_read("basher_tuning.json");
        var _json = "";
        while (!file_text_eof(_file)) { _json += file_text_read_string(_file); file_text_readln(_file); }
        file_text_close(_file);
        try
        {
            var _saved = json_parse(_json);
            if (is_struct(_saved))
            {
                for (var _i = 0; _i < array_length(basher_controls); ++_i)
                {
                    var _control = basher_controls[_i];
                    if (!variable_struct_exists(_saved, _control.key)) continue;
                    var _value = variable_struct_get(_saved, _control.key);
                    if (is_real(_value)) variable_struct_set(global.basher_tuning, _control.key, clamp(_value, _control.lo, _control.hi));
                }
            }
        }
        catch (_error) { show_debug_message("Basher tuner: using defaults for unreadable settings."); }
    }
    global.basher_tuning_revision = 0;
    global.basher_tuner_open = false;
    global.basher_tuner_target = id;
    global.basher_tuner_motion = 0;
}
basher_tuning_revision = -1;
basher_tuner_page = 0;
basher_tuner_drag = -1;
basher_tuner_notice = "Use Movement to tune walking. F6 hides.";

basher_tuner_save = function(_copy)
{
    var _json = json_stringify(global.basher_tuning, true);
    var _file = file_text_open_write("basher_tuning.json");
    if (_file != -1) { file_text_write_string(_file, _json); file_text_close(_file); }
    if (_copy) clipboard_set_text(_json);
    basher_tuner_notice = _copy ? "Copied! Paste the values into chat." : "Settings saved for the next run.";
};

basher_apply_tuning = function()
{
    var _t = global.basher_tuning;
    var _reshape = !variable_instance_exists(id, "basher_last_tuning");
    if (!_reshape)
    {
        for (var _i = 0; _i < array_length(basher_controls); ++_i)
        {
            var _control = basher_controls[_i];
            if (_control.page != 1 && variable_struct_get(_t, _control.key) != variable_struct_get(basher_last_tuning, _control.key)) _reshape = true;
        }
    }
    var _old_height = basher_config.standing_height;
    var _old_centre = basher_config.body_pivot[0];
    var _cfg = variable_clone(basher_base_config);
    _cfg.body_scale = _t.body_scale;
    _cfg.leg_scale = _t.leg_scale;
    _cfg.upper_length = _t.upper_length * _t.leg_scale;
    _cfg.lower_length = _t.lower_length * _t.leg_scale;
    _cfg.foot_scale = _t.foot_scale * _t.leg_scale;
    _cfg.foot_sole *= _cfg.foot_scale;
    _cfg.body_pivot = [36 * _t.body_scale, 14 * _t.body_scale];
    _cfg.standing_height = max(29 * _t.body_scale + 1, _t.hip_y * _t.body_scale + 12 * _t.leg_scale + _t.body_height);
    _cfg.stride_distance = _t.stride_distance * _t.leg_scale;
    _cfg.step_lead = _t.step_lead * _t.leg_scale;
    _cfg.step_height = _t.step_height * _t.leg_scale;
    _cfg.step_duration = _t.step_duration;
    _cfg.step_pause = _t.step_pause;
    _cfg.step_arc = _t.step_arc;
    _cfg.step_smoothing = _t.step_smoothing;
    _cfg.body_wait_for_legs = _t.body_wait_for_legs >= 0.5;
    _cfg.reach_anticipation = _t.reach_anticipation;
    _cfg.walk_speed = _t.walk_speed * _t.leg_scale;
    _cfg.upper_pivot = [_t.upper_pivot_x, _t.upper_pivot_y];
    _cfg.upper_end = [_t.upper_end_x, _t.upper_end_y];
    _cfg.lower_pivot = [_t.lower_pivot_x, _t.lower_pivot_y];
    _cfg.lower_end = [_t.lower_end_x, _t.lower_end_y];
    _cfg.foot_pivot = [_t.foot_pivot_x, _t.foot_pivot_y];
    var _centre = (_t.rear_hip_x + _t.front_hip_x) * 0.5 * _t.body_scale;
    for (var _i = 0; _i < 4; ++_i)
    {
        var _leg = _cfg.legs[_i];
        var _front = (_i == 1 || _i == 3);
        var _hip_x = (_front ? _t.front_hip_x : _t.rear_hip_x) * _t.body_scale;
        _leg.knee_sign = (_front ? _t.front_knee_flip : _t.rear_knee_flip) >= 0.5 ? -1 : 1;
        _leg.lift_multiplier = _front ? _t.front_lift : _t.rear_lift;
        _leg.hip = [_hip_x, (_t.hip_y + (_leg.near ? _t.near_hip_y : 0)) * _t.body_scale];
        _leg.home_x = _centre + (_hip_x - _centre) * _t.foot_spacing
            + (-20 * _t.foot_reach + (_leg.near ? _t.near_foot_offset : 0) + _t.foot_shift) * _t.leg_scale;
    }
    if (_reshape && basher_ready)
    {
        // Keep the ground and body centre anchored during a size change.
        y += _old_height - _cfg.standing_height;
        x += _old_centre - _cfg.body_pivot[0];
    }
    basher_config = _cfg;
    image_xscale = _cfg.body_scale;
    image_yscale = _cfg.body_scale;
    if (_reshape)
    {
        basher_ready = false;
        basher_active_pair = -1;
        basher_step_time = 0;
        basher_step_pause_remaining = 0;
    }
    basher_last_tuning = variable_clone(_t);
    basher_tuning_revision = global.basher_tuning_revision;
};

basher_tuner_layout = function()
{
    var _scale = max(0.1, min(1, min(display_get_gui_height() / 720, display_get_gui_width() / 960)));
    return { scale: _scale, left: display_get_gui_width() - 360 * _scale, width: 360 * _scale };
};

basher_tuner_buttons = function()
{
    var _buttons = [
        { label: "Size", x: 12, y: 210, w: 82, kind: 0, value: 0 },
        { label: "Movement", x: 96, y: 210, w: 82, kind: 0, value: 1 },
        { label: "Hips", x: 180, y: 210, w: 82, kind: 0, value: 2 },
        { label: "Pivots", x: 264, y: 210, w: 82, kind: 0, value: 3 },
        { label: "Stand", x: 12, y: 614, w: 108, kind: 1, value: 0 },
        { label: "Walk left", x: 124, y: 614, w: 108, kind: 1, value: -1 },
        { label: "Walk right", x: 236, y: 614, w: 110, kind: 1, value: 1 },
        { label: "Copy + save", x: 12, y: 654, w: 210, kind: 2, value: 0 },
        { label: "Reset defaults", x: 228, y: 654, w: 118, kind: 3, value: 0 },
        { label: "Next Basher", x: 238, y: 34, w: 108, kind: 4, value: 0 }
    ];
    if (basher_tuner_page == 1)
    {
        array_push(_buttons, { label: "Body waits for legs: " + (global.basher_tuning.body_wait_for_legs >= 0.5 ? "ON" : "OFF"),
            x: 12, y: 246, w: 334, kind: 5, value: 0 });
    }
    return _buttons;
};

basher_apply_tuning();
