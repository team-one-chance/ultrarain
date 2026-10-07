// Let slam knockback run without separation fighting it.
if (slam_knockback_timer > 0 || slam_stun_timer > 0)
{
    exit;
}

var _dt = delta_time / 1000000;

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