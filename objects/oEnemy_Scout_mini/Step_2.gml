// Dev AI freeze keeps drawing and damage available.
if (variable_global_exists("dev_freeze_enemies") && global.dev_freeze_enemies) exit;

// =====================================
// CROWD SPACING â€” AFTER NORMAL MOVEMENT
// =====================================
if (!crowd_spacing_paused && crowd_can_separate())
{
    var _crowd_dt = (variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000;
    var _crowd_centre = (bbox_left + bbox_right) * 0.5;
    var _crowd_width = bbox_right - bbox_left + 1;
    var _crowd_feet = bbox_bottom;
    var _crowd_push_left = 0;
    var _crowd_push_right = 0;

    with (oEnemy_Scout_mini)
    {
        if (
            id != other.id
            && !crowd_spacing_paused
            && crowd_can_separate()
            && abs(bbox_bottom - _crowd_feet)
                <= other.crowd_floor_tolerance
        )
        {
            var _peer_centre = (bbox_left + bbox_right) * 0.5;
            var _peer_width = bbox_right - bbox_left + 1;
            var _peer_dx = _crowd_centre - _peer_centre;

            var _spacing = max(
                max(other.crowd_min_spacing, crowd_min_spacing),
                (_crowd_width + _peer_width) * 0.5
                    + max(other.crowd_body_gap, crowd_body_gap)
            );

            // Allow for a neighbour moving after this End Step runs.
            _spacing += max(
                other.ground_move_speed,
                ground_move_speed
            ) * _crowd_dt;

            var _overlap = _spacing - abs(_peer_dx);

            if (_overlap > 0)
            {
                var _away = sign(_peer_dx);

                // Stable direction when two enemies start at the same X.
                if (_away == 0)
                {
                    _away = (other.id > id) ? 1 : -1;
                }

                if (_away > 0)
                {
                    _crowd_push_right = max(_crowd_push_right, _overlap);
                }
                else
                {
                    _crowd_push_left = max(_crowd_push_left, _overlap);
                }
            }
        }
    }

    var _crowd_move = _crowd_push_right - _crowd_push_left;

    // Find the middle when neighbours squeeze from both sides.
    if (_crowd_push_right > 0 && _crowd_push_left > 0)
    {
        _crowd_move *= 0.5;
    }

    var _crowd_limit = crowd_separation_speed * _crowd_dt;
    _crowd_move = clamp(_crowd_move, -_crowd_limit, _crowd_limit);

    // Sweep in <=1px steps: do not move through walls or off ledges.
    var _crowd_steps = ceil(abs(_crowd_move));

    if (_crowd_steps > 0)
    {
        var _crowd_step = _crowd_move / _crowd_steps;

        repeat (_crowd_steps)
        {
            if (
                place_meeting(x + _crowd_step, y, o_Block)
                || !place_meeting(
                    x + _crowd_step,
                    y + ground_check_distance,
                    o_Block
                )
            )
            {
                break;
            }

            x += _crowd_step;
        }
    }
}
