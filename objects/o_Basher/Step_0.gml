if (variable_global_exists("dev_freeze_enemies") && global.dev_freeze_enemies) exit;
var _dt = clamp((variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) / 1000000, 0, 0.05);
var _cfg = basher_config;
hit_timer = max(0, hit_timer - _dt);

// Initialise after room instances exist. Never invent a planted contact.
if (!basher_ready)
{
    var _floor = basher_ground(x + _cfg.body_pivot[0], y + 29);
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
        var _distance = point_distance(x + _cfg.legs[_i].hip[0], _body_y + _cfg.legs[_i].hip[1], _fx, _fy);
        if (_distance >= _cfg.upper_length + _cfg.lower_length || _distance <= abs(_cfg.upper_length - _cfg.lower_length)) exit;
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
// Retain the inherited damage reaction without snapping planted feet.
if (knockback_timer > 0)
{
    knockback_timer = max(0, knockback_timer - _dt);
    _direction = 0;
}

// Small collision increments prevent crossing thin walls. Refuse ledges
// and poses that would pull any currently planted leg out of reach.
var _remaining = _direction * max(0, _cfg.walk_speed) * _dt;
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
        if (_d >= _cfg.upper_length + _cfg.lower_length - 1 || _d <= abs(_cfg.upper_length - _cfg.lower_length) + 1) _safe = false;
    }
    if (!_safe) break;
    x = _nx;
    y = _ny;
    _remaining -= _move;
}

if (basher_active_pair != -1)
{
    basher_step_time += _dt;
    var _t = clamp(basher_step_time / max(0.001, _cfg.step_duration), 0, 1);
    var _ease = _t * _t * (3 - 2 * _t);
    for (var _i = 0; _i < 4; ++_i)
    {
        if (_cfg.legs[_i].pair != basher_active_pair) continue;
        var _leg = basher_legs[_i];
        _leg.foot_x = lerp(_leg.from_x, _leg.to_x, _ease);
        _leg.foot_y = lerp(_leg.from_y, _leg.to_y, _ease) - sin(pi * _t) * max(0, _cfg.step_height);
        _leg.foot_angle = _leg.from_angle + angle_difference(_leg.to_angle, _leg.from_angle) * _ease;
    }
    if (_t >= 1)
    {
        basher_pair = 1 - basher_active_pair;
        basher_active_pair = -1;
    }
}

if (basher_active_pair == -1)
{
    var _needs_step = false;
    // Prefer the next diagonal. On reversal the other pair can become
    // overdue first; let it recover rather than waiting at full reach.
    for (var _attempt = 0; _attempt < 2; ++_attempt)
    {
        var _candidate_pair = (_attempt == 0) ? basher_pair : 1 - basher_pair;
        for (var _i = 0; _i < 4; ++_i)
        {
            if (_cfg.legs[_i].pair != _candidate_pair) continue;
            if (abs(basher_legs[_i].foot_x - (x + _cfg.legs[_i].home_x)) >= max(1, _cfg.stride_distance) - 0.01) _needs_step = true;
        }
        if (_needs_step) { basher_pair = _candidate_pair; break; }
    }
    if (_needs_step)
    {
        var _targets = [];
        var _valid = true;
        for (var _i = 0; _i < 4; ++_i)
        {
            if (_cfg.legs[_i].pair != basher_pair) continue;
            var _tx = x + _cfg.legs[_i].home_x + _direction * _cfg.step_lead;
            var _gy = basher_ground(_tx, y + _cfg.standing_height);
            if (is_undefined(_gy)) { _valid = false; break; }
            var _angle = basher_ground_angle(_tx, _gy);
            var _ty = _gy - _cfg.foot_sole * dcos(_angle);
            var _d = point_distance(x + _cfg.legs[_i].hip[0], y + _cfg.legs[_i].hip[1], _tx, _ty);
            if (_d >= _cfg.upper_length + _cfg.lower_length - 1 || _d <= abs(_cfg.upper_length - _cfg.lower_length) + 1) { _valid = false; break; }
            array_push(_targets, { index: _i, tx: _tx, ty: _ty, angle: _angle });
        }
        if (_valid)
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
            basher_active_pair = basher_pair;
            basher_step_time = 0;
        }
    }
}
