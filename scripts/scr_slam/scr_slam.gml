/// Call once when the player's slam lands. Radius is measured to enemy masks' bounding boxes.
function slam_apply(_x, _y, _radius, _damage, _speed, _source)
{
    with (oEnemyParent)
    {
        var nearest_x = clamp(_x, bbox_left, bbox_right);
        var nearest_y = clamp(_y, bbox_top, bbox_bottom);

        if (point_distance(_x, _y, nearest_x, nearest_y) <= _radius)
        {
            take_slam(_damage, _speed, _x, _y, _source);
        }
    }
}

/// Runs in the affected enemy's instance context.
function enemy_receive_slam(_damage, _speed, _impact_x, _impact_y, _source)
{
    if (!slam_enabled) return;

    var centre_x = (bbox_left + bbox_right) * 0.5;
    var centre_y = (bbox_top + bbox_bottom) * 0.5;
    var launch_dir = point_direction(_impact_x, _impact_y, centre_x, centre_y);
    if (point_distance(_impact_x, _impact_y, centre_x, centre_y) < 0.001)
    {
        launch_dir = 90;
    }

    var launch_speed = max(0, _speed * slam_knockback_multiplier);
    var push_time = max(0, slam_knockback_duration);
    var stun_time = max(0, slam_stun_duration);

    // A zero duration/multiplier disables only that effect.
    if (launch_speed > 0 && push_time > 0)
    {
        slam_knockback_timer = max(slam_knockback_timer, push_time);
        slam_velocity_x = lengthdir_x(launch_speed, launch_dir);
        slam_velocity_y = lengthdir_y(launch_speed, launch_dir);
    }
    slam_stun_timer = max(slam_stun_timer, stun_time);

    if (slam_knockback_timer > 0 || slam_stun_timer > 0)
    {
        slam_interrupt();
    }

    // Damage last: the response may destroy the enemy.
    slam_damage(max(0, _damage * slam_damage_multiplier), _impact_x, _source);
}

/// Call ONCE per enemy Step. Return true to suppress that frame's normal AI.
/// The miniboss calls this through its inherited parent Step.
function enemy_slam_step(_dt)
{
    var blocked = slam_knockback_timer > 0 || slam_stun_timer > 0;
    if (!blocked) return false;

    path_end();
    var step_time = max(0, _dt);

    if (slam_knockback_timer > 0)
    {
        var move_time = min(step_time, slam_knockback_timer);
        var move_x = slam_velocity_x * move_time;
        var move_y = slam_velocity_y * move_time;

        // Sweep each axis in <= 1-pixel steps to avoid crossing thin walls.
        var steps_x = max(1, ceil(abs(move_x)));
        var pixel_x = move_x / steps_x;
        repeat (steps_x)
        {
            if (place_meeting(x + pixel_x, y, o_Block))
            {
                slam_velocity_x = 0;
                break;
            }
            x += pixel_x;
        }

        var steps_y = max(1, ceil(abs(move_y)));
        var pixel_y = move_y / steps_y;
        repeat (steps_y)
        {
            if (place_meeting(x, y + pixel_y, o_Block))
            {
                slam_velocity_y = 0;
                break;
            }
            y += pixel_y;
        }

        // Exponential decay stays consistent across different frame rates.
        var decay = exp(-max(0, slam_knockback_drag) * move_time);
        slam_velocity_x *= decay;
        slam_velocity_y *= decay;
        slam_knockback_timer = max(0, slam_knockback_timer - step_time);
        if (slam_knockback_timer <= 0)
        {
            slam_velocity_x = 0;
            slam_velocity_y = 0;
        }
    }

    slam_stun_timer = max(0, slam_stun_timer - step_time);
    return true; // AI resumes on the following frame, even if timers expired here.
}
