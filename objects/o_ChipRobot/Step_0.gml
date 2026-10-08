if (variable_global_exists("dev_freeze_enemies") && global.dev_freeze_enemies) exit;
var _dt = chip_dt();
hit_timer = max(0, hit_timer - _dt);
path_end();

if (enemy_slam_step(_dt))
{
    chip_gravity(_dt);
    exit;
}
if (knockback_timer > 0)
{
    knockback_timer = max(0, knockback_timer - _dt);
    var _dx = knockback_x * knockback_move_multiplier;
    var _dy = knockback_y * knockback_move_multiplier;
    var _n = max(1, ceil(max(abs(_dx), abs(_dy))));
    repeat (_n)
    {
        if (!chip_wall_at(x + _dx / _n, y)) x += _dx / _n;
        if (!chip_wall_at(x, y + _dy / _n)) y += _dy / _n;
    }
    knockback_x *= knockback_decay;
    knockback_y *= knockback_decay;
    chip_gravity(_dt);
    exit;
}

chip_gravity(_dt);
if (y > room_height + 64) { instance_destroy(); exit; }
chip_state_timer = max(0, chip_state_timer - _dt);
var _player = instance_nearest(x, y, o_Player);
if (instance_exists(_player)) chip_last_player_x = _player.x;

// Only a sustained, nearly stationary WALL HOLD permits the offensive throw.
if (instance_exists(_player)
&& _player.chip_wall_holding_now
&& abs(_player.phy_speed_y) < 1
&& abs(_player.phy_speed_x) < 1
&& _player.y < y - 40
&& point_distance(x, y - 20, _player.x, _player.y - 32) <= chip_throw_range)
{
    if (chip_wall_target != _player) chip_wall_watch_timer = 0;
    chip_wall_target = _player;
    chip_wall_watch_timer += _dt;
}
else
{
    chip_wall_watch_timer = 0;
    chip_wall_target = noone;
}

switch (chip_state)
{
    case ChipRobotState.CHOOSE:
    {
        if (chip_state_timer > 0) break;
        if (!chip_has_chip) { chip_begin_retreat(); break; }
        chip_support_action = irandom(2) == 0;
        chip_target = chip_support_action ? chip_find_heal_target(id) : noone;
        if (chip_target != noone)
        {
            chip_throw_is_healing = true;
            chip_set_state(ChipRobotState.THROW, chip_throw_windup);
        }
        else
        {
            chip_support_action = false;
            chip_set_state(ChipRobotState.APPROACH);
        }
        break;
    }
    case ChipRobotState.APPROACH:
    {
        if (!instance_exists(_player)) break;
        chip_facing = sign(_player.x - x);
        if (chip_facing == 0) chip_facing = 1;
        if (chip_wall_watch_timer >= chip_wall_watch_duration)
        {
            // Lock the throw direction at the start of the visible windup.
            chip_throw_is_healing = false;
            chip_throw_angle = point_direction(x, y - 20, _player.x, _player.y - 32);
            var _wall = collision_line(x, y - 20, _player.x, _player.y - 32, o_Block, false, true);
            if (_wall == noone)
                chip_set_state(ChipRobotState.THROW, chip_throw_windup);
            break;
        }
        if (is_grounded
        && abs(_player.x - x) <= chip_attack_range
        && abs(_player.bbox_bottom - bbox_bottom) <= 36)
        {
            chip_dash_direction = chip_facing;
            chip_dash_player_x = _player.x;
            chip_dash_hit_tested = false;
            chip_dash_missed = false;
            chip_set_state(ChipRobotState.WINDUP, chip_windup_duration);
            break;
        }
        chip_walk(chip_facing, ground_move_speed, _dt, false);
        break;
    }
    case ChipRobotState.WINDUP:
    {
        // Direction stays locked even when the player changes sides.
        if (chip_state_timer <= 0)
            chip_set_state(ChipRobotState.DASH);
        break;
    }
    case ChipRobotState.DASH:
    {
        chip_facing = chip_dash_direction;
        if (instance_exists(_player)) chip_dash_player_x = _player.x;
        chip_dash_move(chip_dash_direction * chip_dash_speed * _dt);
        // Damage may have destroyed this instance during the swept movement.
        if (ehp <= 0) exit;
        break;
    }
    case ChipRobotState.THROW:
    {
        if (chip_throw_is_healing && instance_exists(chip_target))
        {
            chip_facing = sign(chip_target.x - x);
            if (chip_facing == 0) chip_facing = 1;
        }
        if (chip_state_timer > 0) break;
        if (chip_throw_is_healing)
        {
            if (!chip_send_heal(chip_target))
            {
                if (chip_force_support) chip_begin_retreat();
                else chip_set_state(ChipRobotState.CHOOSE, 0.5);
            }
        }
        else chip_send_attack();
        break;
    }
    case ChipRobotState.RETREAT:
    {
        if (chip_force_support && chip_has_chip)
        {
            chip_target = chip_find_heal_target(id);
            if (chip_target != noone)
            {
                // Put some distance between the hit and the support action.
                if (!instance_exists(_player) || abs(x - _player.x) >= 160 || !chip_visible(id))
                {
                    chip_throw_is_healing = true;
                    chip_set_state(ChipRobotState.THROW, chip_throw_windup);
                    break;
                }
            }
            else
            {
                // Keep the bonus for the next eligible heal; don't get stuck forever.
                chip_force_support = false;
                chip_set_state(ChipRobotState.CHOOSE, 1);
                break;
            }
        }
        if (!chip_has_chip && !chip_visible(id))
        {
            chip_set_state(ChipRobotState.REBUILD, chip_rebuild_duration);
            break;
        }
        chip_walk(chip_retreat_direction, retreat_speed, _dt, true);
        break;
    }
    case ChipRobotState.REBUILD:
    {
        // Offscreen is required to START; returning onscreen does not reset it.
        if (chip_state_timer <= 0)
        {
            chip_has_chip = true;
            chip_set_state(ChipRobotState.CHOOSE, 0.5);
        }
        break;
    }
    case ChipRobotState.STUN:
    {
        if (chip_state_timer <= 0) chip_begin_retreat();
        break;
    }
}
