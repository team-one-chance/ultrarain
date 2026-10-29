function raycast_wall_distance(_start_x, _start_y, _direction, _range)
{
    // =====================================
    // CALCULATE FULL RAY END
    // =====================================

    var end_x = _start_x + lengthdir_x(_range, _direction);
    var end_y = _start_y + lengthdir_y(_range, _direction);


    // =====================================
    // CHECK IF THE RAY HITS A WALL
    // =====================================

    var wall_hit = collision_line(
        _start_x,
        _start_y,
        end_x,
        end_y,
        o_Block,
        false,
        true
    );

    // No wall found: use the full range
    if (wall_hit == noone)
    {
        return _range;
    }


    // =====================================
    // BINARY SEARCH
    // =====================================

    var low = 0;
    var high = _range;

    for (var i = 0; i < 15; i++)
    {
        var mid = (low + high) / 2;

        var check_x = _start_x + lengthdir_x(mid, _direction);
        var check_y = _start_y + lengthdir_y(mid, _direction);

        var hit = collision_point(
            check_x,
            check_y,
            o_Block,
            false,
            true
        );

        if (hit != noone)
        {
            high = mid;
        }
        else
        {
            low = mid;
        }
    }

    return high;
}