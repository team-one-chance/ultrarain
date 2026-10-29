if (variable_instance_exists(id, "train_departing") && train_departing)
{
    path_end();
    speed = 0;
    exit;
}
// Dev AI freeze keeps drawing and damage available.
if (variable_global_exists("dev_freeze_enemies") && global.dev_freeze_enemies) exit;

// Check the complete movement since Begin Step.
// Automatic path movement has already happened by End Step.
var _move_x = x - drone_frame_start_x;
var _move_y = y - drone_frame_start_y;

x = drone_frame_start_x;
y = drone_frame_start_y;

var _steps = max(
    1,
    ceil(max(abs(_move_x), abs(_move_y)))
);

var _step_x = _move_x / _steps;
var _step_y = _move_y / _steps;

var _hit_wall = false;
var _hit_x = false;
var _hit_y = false;

repeat (_steps)
{
    if (place_meeting(x + _step_x, y + _step_y, o_Block))
    {
        _hit_wall = true;

        _hit_x = (
            _step_x != 0
            && place_meeting(x + _step_x, y, o_Block)
        );

        _hit_y = (
            _step_y != 0
            && place_meeting(x, y + _step_y, o_Block)
        );

        // A diagonal corner can block both axes together.
        if (!_hit_x && !_hit_y)
        {
            _hit_x = true;
            _hit_y = true;
        }

        break;
    }

    x += _step_x;
    y += _step_y;
}

if (_hit_wall)
{
    path_end();
    speed = 0;
    repath_timer = 0;

    // Reflect the attempted movement away from the wall.
    var _away_x = _hit_x ? -_move_x : _move_x;
    var _away_y = _hit_y ? -_move_y : _move_y;

    var _length = max(
        0.001,
        point_distance(0, 0, _away_x, _away_y)
    );

    drone_bump_velocity_x =
        _away_x / _length * drone_bump_speed;

    drone_bump_velocity_y =
        _away_y / _length * drone_bump_speed;

    if (drone_bump_timer <= 0)
    {
        orbit_direction *= -1;
        chase_direction *= -1;
    }

    drone_bump_timer = drone_bump_duration;
}

// Let slam knockback run without separation fighting it.
if (slam_knockback_timer > 0 || slam_stun_timer > 0)
{
    exit;
}

var _dt = (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) / 1000000;

for (var _i = 0; _i < instance_number(oDrone); _i++)
{
    var _other = instance_find(oDrone, _i);

    if (_other == id) continue;

    var _cx = (bbox_left + bbox_right) * 0.5;
    var _cy = (bbox_top + bbox_bottom) * 0.5;

    var _ox = (_other.bbox_left + _other.bbox_right) * 0.5;
    var _oy = (_other.bbox_top + _other.bbox_bottom) * 0.5;

    var _distance = point_distance(_cx, _cy, _ox, _oy);

    if (_distance >= drone_separation_radius) continue;

    // Update the route from our adjusted position next Step.
    repath_timer = 0;

    var _away;

    if (_distance < 0.001)
    {
        _away = (id < _other.id) ? 0 : 180;
    }
    else
    {
        _away = point_direction(_ox, _oy, _cx, _cy);
    }

    var _push = min(
        drone_separation_radius - _distance,
        drone_separation_speed * _dt
    );

    var _move_x = lengthdir_x(_push, _away);
    var _move_y = lengthdir_y(_push, _away);

    var _steps = max(
        1, ceil(max(abs(_move_x), abs(_move_y)))
    );

    var _step_x = _move_x / _steps;
    var _step_y = _move_y / _steps;

    repeat (_steps)
    {
        // Allow already overlapping drones to move apart.
        var _overlapping = place_meeting(x, y, oDrone);

        if (!place_meeting(x + _step_x, y, o_Block)
        && (_overlapping
            || !place_meeting(x + _step_x, y, oDrone)))
        {
            x += _step_x;
        }

        _overlapping = place_meeting(x, y, oDrone);

        if (!place_meeting(x, y + _step_y, o_Block)
        && (_overlapping
            || !place_meeting(x, y + _step_y, oDrone)))
        {
            y += _step_y;
        }
    }
}