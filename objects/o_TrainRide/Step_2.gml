if (!ride_started) exit;

var _dt = max(0, (
    variable_global_exists("dev_delta_time")
    ? global.dev_delta_time
    : delta_time
) / 1000000);

for (var _i = 0; _i < array_length(departure_enemies); _i++)
{
    var _record = departure_enemies[_i];
    var _enemy = _record.enemy;

    if (!instance_exists(_enemy)) continue;

    // Only ground enemies have this gravity system.
    var _uses_gravity =
        variable_instance_exists(_enemy, "vertical_speed")
        && variable_instance_exists(_enemy, "gravity_force")
        && variable_instance_exists(_enemy, "maximum_fall_speed");

    if (_uses_gravity)
    {
        if (!variable_struct_exists(_record, "fall_speed"))
        {
            // Preserve an existing jump instead of freezing it.
            _record.fall_speed = _enemy.vertical_speed;
            _record.settled = false;
        }
    }

    with (_enemy)
    {
        path_end();
        speed = 0;

        // Check platforms at their original world coordinates.
        x = _record.start_x;
        y = _record.start_y;

        if (_uses_gravity)
        {
            var _landed = false;

            if (_record.fall_speed >= 0
            && place_meeting(x, y + 1, o_Block))
            {
                _record.fall_speed = 0;
                _landed = true;
            }
            else
            {
                _record.fall_speed = min(
                    maximum_fall_speed,
                    _record.fall_speed + gravity_force * _dt
                );

                var _move_y = _record.fall_speed * _dt;
                var _steps = max(1, ceil(abs(_move_y)));
                var _step_y = _move_y / _steps;

                repeat (_steps)
                {
                    if (place_meeting(x, y + _step_y, o_Block))
                    {
                        _landed = _step_y > 0;
                        _record.fall_speed = 0;
                        break;
                    }

                    y += _step_y;
                }
            }

            vertical_speed = _record.fall_speed;
            is_grounded = _landed;

            // Stop the miniboss's leap pose once it lands.
            if (_landed && !_record.settled)
            {
                _record.settled = true;

                if (variable_instance_exists(id, "breaker_state"))
                {
                    breaker_set_state(BreakerState.CHASE);
                    sprite_index = breaker_sprite(s_Breaker_idle, s_Breaker_idle_unshielded);
                    image_index = 0;
                }
                else if (variable_instance_exists(id, "miniboss_state"))
                {
                    miniboss_state = 0;
                    leap_horizontal_speed = 0;
                    leap_left_ground = false;
                    leap_aim_locked = false;

                    sprite_index = stand_sprite;
                    image_index = 0;
                }
            }

            _record.start_y = y;
        }

        // Apply the same horizontal offset as the departing scenery.
        x = _record.start_x - other.scenery_distance;
        y = _record.start_y;
    }
}