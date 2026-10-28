event_inherited();
ehp_max = 75;
ehp = ehp_max;
hit_duration = 0.15;
hit_timer = 0;
normal_sprite = sprite_index;
mask_index = sprite_index;
image_speed = 0;
image_xscale = 1;
image_yscale = 1;

// Ground movement is pixels per second; this object does NOT use physics.
ground_move_speed = 160;
retreat_speed = 230;
chip_separation_gap = 8;
chip_separation_speed = 300;
vertical_speed = 0;
gravity_force = 900;
maximum_fall_speed = 500;
ground_jump_speed = -330;
ground_check_distance = 1;
is_grounded = false;

chip_state = ChipRobotState.CHOOSE;
chip_state_timer = random_range(0.4, 1);
chip_has_chip = true;
chip_heal_bonus = 0;
chip_force_support = false;
chip_target = noone;
chip_facing = 1;
chip_retreat_direction = choose(-1, 1);
chip_support_action = false;
chip_throw_is_healing = false;
chip_throw_angle = 0;
chip_wall_watch_timer = 0;
chip_wall_target = noone;
chip_dash_direction = 1;
chip_dash_hit_tested = false;
chip_dash_missed = false;
chip_dash_player_dodged = false;
chip_dash_current_speed = 0;
chip_dash_player_x = x;
chip_last_player_x = x;

// Tuning.
chip_attack_range = 1800;
chip_windup_duration = 0.65;
chip_windup_duration = 0.65;
chip_dash_speed = 500;          // Starting speed, pixels per second.
chip_dash_acceleration = 100;   // Adds 100 pixels/second each second.
chip_throw_windup = 0.7;
chip_throw_range = 420;
chip_wall_watch_duration = 0.65;
chip_rebuild_duration = 8;
chip_self_heal = 25;
chip_ally_heal_fraction = 0.35;
chip_ally_heal_cap = 35;
chip_bonus_heal = 10;
chip_crash_damage = 10;
chip_missed_crash_damage = 20;

chip_set_state = function(_state, _timer = 0)
{
    chip_state = _state;
    chip_state_timer = _timer;
};

chip_begin_retreat = function()
{
    var _player = instance_nearest(x, y, o_Player);
    chip_retreat_direction = instance_exists(_player) ? sign(x - _player.x) : choose(-1, 1);
    if (chip_retreat_direction == 0) chip_retreat_direction = choose(-1, 1);
    chip_set_state(ChipRobotState.RETREAT);
};

chip_request_boosted_heal = function()
{
    chip_has_chip = true;
    chip_heal_bonus = chip_bonus_heal;
    chip_force_support = true;
    chip_begin_retreat();
};

chip_send_heal = function(_target)
{
    if (!instance_exists(_target)) return false;
    var _amount = (_target == id)
        ? chip_self_heal
        : min(chip_ally_heal_cap, _target.ehp_max * chip_ally_heal_fraction);
    _amount += chip_heal_bonus;
    if (_target == id)
    {
        if (!chip_attach_heal(id, _amount)) return false;
    }
    else
    {
        var _shot = instance_create_depth(x, y - 20, depth - 2, o_ChipProjectile);
        _shot.owner = id;
        _shot.target = _target;
        _shot.is_healing = true;
        _shot.heal_amount = _amount;
        _shot.travel_angle = point_direction(
            _shot.x, _shot.y,
            (_target.bbox_left + _target.bbox_right) * 0.5,
            (_target.bbox_top + _target.bbox_bottom) * 0.5
        );
    }
    chip_has_chip = false;
    chip_heal_bonus = 0;
    chip_force_support = false;
    chip_begin_retreat();
    return true;
};

chip_send_attack = function()
{
    var _shot = instance_create_depth(x, y - 20, depth - 2, o_ChipProjectile);
    _shot.owner = id;
    _shot.travel_angle = chip_throw_angle;
    chip_has_chip = false;
    chip_begin_retreat();
};

chip_crash = function(_enemy)
{
    var _amount = chip_dash_missed ? chip_missed_crash_damage : chip_crash_damage;
    chip_has_chip = false;
    chip_heal_bonus = 0;
    chip_force_support = false;
    chip_set_state(ChipRobotState.STUN, 4);
    if (instance_exists(_enemy)) chip_crash_enemy(_enemy, _amount);
    // Save no references to a potentially destroyed enemy after the call.
    take_damage(_amount, 0, 0, false);
};

// Walls always stop the charge.
// Enemies only stop it after the player dodges using dash iFrames.
chip_dash_move = function(_amount)
{
    var _steps = max(1, ceil(abs(_amount)));
    var _step = _amount / _steps;
    var _hits = ds_list_create();

    for (var _i = 0; _i < _steps; _i++)
    {
        if (chip_wall_at(x + _step, y))
        {
            ds_list_destroy(_hits);
            chip_crash(noone);
            return true;
        }

        x += _step;

        // Test the player before other enemies.
        if (!chip_dash_hit_tested)
        {
            var _player = instance_place(x, y, o_Player);

            if (_player != noone)
            {
                chip_dash_hit_tested = true;
				if (_player.parry_melee(id, true))
{
    ds_list_destroy(_hits);
    return true;
}

                // This method also refreshes active ground-dash iFrames.
                var _dash_protected = _player.dash_blocks_damage();

                var _result = _player.chip_receive_hit(x, false);

                if (_result == 2)
                {
                    ds_list_destroy(_hits);
                    chip_request_boosted_heal();
                    return false;
                }

                if (_result == 1)
                {
                    chip_has_chip = false;
                    ds_list_destroy(_hits);
                    chip_begin_retreat();
                    return false;
                }

                // The hit was blocked. Only dash protection enables
                // crashes into other enemies.
                chip_dash_player_dodged = _dash_protected;
                chip_dash_missed = true;
            }
        }

        if (chip_dash_player_dodged)
        {
            ds_list_clear(_hits);

            collision_rectangle_list(
                bbox_left,
                bbox_top,
                bbox_right,
                bbox_bottom,
                oEnemyParent,
                false,
                true,
                _hits,
                false
            );

            if (ds_list_size(_hits) > 0)
            {
                var _enemy = _hits[| 0];

                ds_list_destroy(_hits);
                chip_crash(_enemy);
                return true;
            }
        }

        if ((x - chip_dash_player_x) * chip_dash_direction > 24)
        {
            chip_dash_missed = true;
        }

        if (x < 24 || x > room_width - 24)
        {
            ds_list_destroy(_hits);
            chip_crash(noone);
            return true;
        }
    }

    ds_list_destroy(_hits);
    return false;
};

chip_walk = function(_direction, _speed, _dt, _retreat)
{
    if (_direction == 0) return;
    chip_facing = _direction;
    var _amount = _direction * _speed * _dt;
    var _steps = max(1, ceil(abs(_amount)));
    var _step = _amount / _steps;
    repeat (_steps)
    {
        if (x + _step < 24 || x + _step > room_width - 24)
        {
            if (_retreat) chip_retreat_direction *= -1;
            break;
        }
        if (chip_wall_at(x + _step, y))
        {
            if (_retreat) chip_retreat_direction *= -1;
            else if (is_grounded) vertical_speed = ground_jump_speed;
            break;
        }
// Pass through enemy bodies while approaching or retreating.
x += _step;
    }
};

chip_gravity = function(_dt)
{
    is_grounded = chip_wall_at(x, y + 1);
    if (is_grounded && vertical_speed >= 0) vertical_speed = 0;
    else vertical_speed = min(maximum_fall_speed, vertical_speed + gravity_force * _dt);
    var _amount = vertical_speed * _dt;
    var _steps = max(1, ceil(abs(_amount)));
    var _step = _amount / _steps;
    repeat (_steps)
    {
        if (chip_wall_at(x, y + _step))
        {
            vertical_speed = 0;
            break;
        }
        y += _step;
    }
    is_grounded = chip_wall_at(x, y + 1);
};

slam_interrupt = function()
{
    path_end();
    chip_set_state(chip_has_chip ? ChipRobotState.CHOOSE : ChipRobotState.RETREAT, 0.6);
};
