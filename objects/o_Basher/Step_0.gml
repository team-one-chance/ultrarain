if (basher_tuning_revision != global.basher_tuning_revision) basher_apply_tuning();
if (variable_global_exists("dev_freeze_enemies") && global.dev_freeze_enemies && !global.basher_tuner_open) exit;
var _dt = clamp((variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) / 1000000, 0, 0.05);
var _cfg = basher_config;
hit_timer = max(0, hit_timer - _dt);
basher_step_pause_remaining = max(0, basher_step_pause_remaining - _dt);

// Initialise after room instances exist. Never invent a planted contact.
if (!basher_ready)
{
    var _floor = basher_ground(x + _cfg.body_pivot[0], y + 29 * _cfg.body_scale);
    if (is_undefined(_floor)) exit;
    var _body_y = _floor - _cfg.standing_height;
    var _initial = [];
    for (var _i = 0; _i < 4; ++_i)
    {
        var _fx = x + _cfg.legs[_i].home_x;
        var _gy = basher_ground(_fx, _floor);
        if (is_undefined(_gy)) exit;
        var _angle = basher_ground_angle(_fx, _gy);
        var _fy = _gy - _cfg.foot_sole * dcos(_angle);
        var _contact = basher_foothold(_i, _fx, x, _body_y);
        if (!is_undefined(_contact))
        {
            _fx = _contact.tx;
            _fy = _contact.ty;
            _angle = _contact.angle;
        }
        var _distance = point_distance(x + _cfg.legs[_i].hip[0], _body_y + _cfg.legs[_i].hip[1], _fx, _fy);
        // Keep the rig visible while experimenting with unreachable settings.
        if (!global.basher_tuner_open && (_distance >= _cfg.upper_length + _cfg.lower_length || _distance <= abs(_cfg.upper_length - _cfg.lower_length))) exit;
        array_push(_initial, { foot_x: _fx, foot_y: _fy, foot_angle: _angle,
            from_x: _fx, from_y: _fy, to_x: _fx, to_y: _fy,
            from_angle: _angle, to_angle: _angle });
    }
    y = _body_y;
    basher_legs = _initial;
    basher_ready = true;
}

var _direction = clamp(move_direction, -1, 1);
if (chase_player)
{
    var _player = instance_nearest(x, y, o_Player);
    _direction = 0;
    if (_player != noone && abs(_player.x - (x + _cfg.body_pivot[0])) > _cfg.stop_distance)
        _direction = sign(_player.x - (x + _cfg.body_pivot[0]));
}
if (!walk_enabled) _direction = 0;
if (global.basher_tuner_open)
{
    _direction = (id == global.basher_tuner_target) ? global.basher_tuner_motion : 0;
}
// Retain the inherited damage reaction without snapping planted feet.
if (knockback_timer > 0)
{
    knockback_timer = max(0, knockback_timer - _dt);
    _direction = 0;
}

// Always respect walls and ledges. Waiting for support feet is optional.
var _remaining = _direction * max(0, _cfg.walk_speed) * _dt;
var _reach_blocked = [false, false];
var _reach_margin = min(1, min(_cfg.upper_length, _cfg.lower_length) * 0.05);
var _reach_min = abs(_cfg.upper_length - _cfg.lower_length) + _reach_margin;
var _reach_max = _cfg.upper_length + _cfg.lower_length - _reach_margin;
while (abs(_remaining) > 0.0001)
{
    var _move = sign(_remaining) * min(1, abs(_remaining));
    var _nx = x + _move;
    var _ground = basher_ground(_nx + _cfg.body_pivot[0], y + _cfg.standing_height);
    if (is_undefined(_ground)) break;
    var _ny = _ground - _cfg.standing_height;
    if (abs(_ny - y) > 2 || place_meeting(_nx, _ny, o_Block)) break;
    var _safe = true;
    for (var _i = 0; _i < 4; ++_i)
    {
        if (_cfg.legs[_i].pair == basher_active_pair) continue;
        var _leg = basher_legs[_i];
        var _d = point_distance(_nx + _cfg.legs[_i].hip[0], _ny + _cfg.legs[_i].hip[1], _leg.foot_x, _leg.foot_y);
        if (_d >= _reach_max || _d <= _reach_min)
        {
            _safe = false;
            _reach_blocked[_cfg.legs[_i].pair] = true;
        }
    }
    if (!_safe && _cfg.body_wait_for_legs) break;
    x = _nx;
    y = _ny;
    _remaining -= _move;
}

if (basher_active_pair != -1)
{
    basher_step_time += _dt;
    var _t = clamp(basher_step_time / max(0.001, _cfg.step_duration), 0, 1);
    var _ease = lerp(_t, _t * _t * (3 - 2 * _t), _cfg.step_smoothing);
    for (var _i = 0; _i < 4; ++_i)
    {
        if (_cfg.legs[_i].pair != basher_active_pair) continue;
        var _leg = basher_legs[_i];
        _leg.foot_x = lerp(_leg.from_x, _leg.to_x, _ease);
        var _arc = power(max(0, sin(pi * _t)), _cfg.step_arc);
        _leg.foot_y = lerp(_leg.from_y, _leg.to_y, _ease)
            - _arc * max(0, _cfg.step_height) * _cfg.legs[_i].lift_multiplier;
        _leg.foot_angle = _leg.from_angle + angle_difference(_leg.to_angle, _leg.from_angle) * _ease;
    }
    if (_t >= 1)
    {
        basher_pair = 1 - basher_active_pair;
        basher_active_pair = -1;
        basher_step_pause_remaining = _cfg.step_pause;
    }
}

if (basher_active_pair == -1 && basher_step_pause_remaining <= 0)
{
    // Request a step BEFORE a support foot reaches its limit. Preferred
    // contacts and landing targets use the same reachable-ground solver.
    var _lookahead = _direction * max(1, min(_cfg.stride_distance,
        _cfg.walk_speed * (_cfg.step_duration + _cfg.step_pause + _dt)));
    for (var _attempt = 0; _attempt < 2; ++_attempt)
    {
        var _candidate_pair = (_attempt == 0) ? basher_pair : 1 - basher_pair;
        var _needs_step = _reach_blocked[_candidate_pair];
        for (var _i = 0; _i < 4; ++_i)
        {
            if (_cfg.legs[_i].pair != _candidate_pair) continue;
            var _home = basher_foothold(_i, x + _cfg.legs[_i].home_x, x, y);
            if (is_undefined(_home)) continue;
            var _leg = basher_legs[_i];
            if (abs(_leg.foot_x - _home.tx) >= max(1, _cfg.stride_distance) - 0.01) _needs_step = true;
            if (_direction != 0)
            {
                var _future_distance = point_distance(x + _lookahead + _cfg.legs[_i].hip[0],
                    y + _cfg.legs[_i].hip[1], _leg.foot_x, _leg.foot_y);
                if (_future_distance >= _reach_max || _future_distance <= _reach_min) _needs_step = true;
            }
        }
        if (!_needs_step) continue;
        var _targets = [];
        var _valid = true;
        var _changes_contact = false;
        for (var _i = 0; _i < 4; ++_i)
        {
            if (_cfg.legs[_i].pair != _candidate_pair) continue;
            var _target = basher_foothold(_i,
                x + _cfg.legs[_i].home_x + _direction * _cfg.step_lead, x, y);
            if (is_undefined(_target)) { _valid = false; break; }
            if (point_distance(basher_legs[_i].foot_x, basher_legs[_i].foot_y, _target.tx, _target.ty) > 0.25) _changes_contact = true;
            array_push(_targets, { index: _i, tx: _target.tx, ty: _target.ty, angle: _target.angle });
        }
        if (_valid && _changes_contact)
        {
            for (var _j = 0; _j < array_length(_targets); ++_j)
            {
                var _target = _targets[_j];
                var _leg = basher_legs[_target.index];
                _leg.from_x = _leg.foot_x;
                _leg.from_y = _leg.foot_y;
                _leg.from_angle = _leg.foot_angle;
                _leg.to_x = _target.tx;
                _leg.to_y = _target.ty;
                _leg.to_angle = _target.angle;
            }
            basher_active_pair = _candidate_pair;
            basher_step_time = 0;
            break;
        }
    }
}
