if (variable_instance_exists(id, "train_departing") && train_departing)
{
    path_end();
    speed = 0;
    exit;
}
if (variable_global_exists("dev_freeze_enemies")
&& global.dev_freeze_enemies)
{
    exit;
}

// Let charges, stuns and knockback control their own movement.
if (chip_state == ChipRobotState.DASH
|| chip_state == ChipRobotState.STUN
|| slam_knockback_timer > 0
|| slam_stun_timer > 0
|| knockback_timer > 0)
{
    exit;
}

var _budget = chip_separation_speed * chip_dt();

for (var _i = 0; _i < instance_number(o_ChipRobot); _i++)
{
    if (_budget <= 0) break;

    var _other = instance_find(o_ChipRobot, _i);

    if (_other == id) continue;
	
	    // Let robots travelling in opposite directions pass through.
    var _my_direction =
        (chip_state == ChipRobotState.RETREAT)
        ? chip_retreat_direction
        : chip_facing;

    var _other_direction =
        (_other.chip_state == ChipRobotState.RETREAT)
        ? _other.chip_retreat_direction
        : _other.chip_facing;

    if (_my_direction * _other_direction < 0)
    {
        continue;
    }

    // Ignore robots on different floors.
    if (bbox_bottom <= _other.bbox_top
    || bbox_top >= _other.bbox_bottom)
    {
        continue;
    }

    var _centre = (bbox_left + bbox_right) * 0.5;
    var _other_centre =
        (_other.bbox_left + _other.bbox_right) * 0.5;

    var _desired_distance =
        (bbox_right - bbox_left + 1) * 0.5
        + (_other.bbox_right - _other.bbox_left + 1) * 0.5
        + chip_separation_gap;

    var _distance = abs(_centre - _other_centre);

    if (_distance >= _desired_distance) continue;

    var _away = sign(_centre - _other_centre);

    // Give exactly overlapping robots opposite directions.
    if (_away == 0)
    {
        _away = (id < _other.id) ? -1 : 1;
    }

    var _push = min(
        (_desired_distance - _distance) * 0.5,
        _budget
    );

    var _steps = max(1, ceil(_push));
    var _step = _away * _push / _steps;

    repeat (_steps)
    {
        var _next_x = x + _step;

        if (_next_x < 24 || _next_x > room_width - 24)
        {
            break;
        }

        if (chip_wall_at(_next_x, y))
        {
            break;
        }

        // Separation alone must not push them off a ledge.
        if (is_grounded && !chip_wall_at(_next_x, y + 1))
        {
            break;
        }

        x = _next_x;
        _budget -= abs(_step);
    }
}