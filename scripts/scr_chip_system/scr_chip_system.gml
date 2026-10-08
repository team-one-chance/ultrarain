enum ChipEffect { GREEN, RED, ORANGE, YELLOW, WHITE }
enum ChipRobotState { CHOOSE, APPROACH, WINDUP, DASH, THROW, RETREAT, REBUILD, STUN }

function chip_dt()
{
    return max(0, (variable_global_exists("dev_delta_time")
        ? global.dev_delta_time : delta_time) / 1000000);
}

function chip_wall_at(_x, _y)
{
    if (place_meeting(_x, _y, o_Block)) return true;
    var _door = instance_place(_x, _y, o_Door_UNB);
    return _door != noone && _door.door_state != 2;
}

function chip_visible(_inst)
{
    if (!view_enabled) return true;
    for (var _v = 0; _v < 8; _v++)
    {
        if (!view_visible[_v] || view_camera[_v] == -1) continue;
        var _cam = view_camera[_v];
        var _cx = camera_get_view_x(_cam);
        var _cy = camera_get_view_y(_cam);
        if (_inst.bbox_right >= _cx
        && _inst.bbox_left <= _cx + camera_get_view_width(_cam)
        && _inst.bbox_bottom >= _cy
        && _inst.bbox_top <= _cy + camera_get_view_height(_cam)) return true;
    }
    return false;
}

function chip_heal_active(_target)
{
    for (var _i = 0; _i < instance_number(o_ChipAttachment); _i++)
    {
        var _chip = instance_find(o_ChipAttachment, _i);
        if (_chip.is_healing && _chip.target == _target) return true;
    }
    return false;
}

function chip_find_heal_target(_owner)
{
    var _targets = [];
    for (var _i = 0; _i < instance_number(oEnemyParent); _i++)
    {
        var _enemy = instance_find(oEnemyParent, _i);
        if (_enemy.ehp <= 0 || _enemy.ehp >= _enemy.ehp_max) continue;
        if (chip_heal_active(_enemy)) continue;
        // Add future flying enemies by giving them chip_flying = true.
        var _flying = _enemy.object_index == oDrone
            || object_is_ancestor(_enemy.object_index, oDrone);
        if (variable_instance_exists(_enemy, "chip_flying"))
            _flying = _flying || _enemy.chip_flying;
        if (_enemy != _owner && !_flying && _enemy.ehp_max <= 101) continue;
        if (point_distance(_owner.x, _owner.y, _enemy.x, _enemy.y) > 650) continue;
        if (_enemy != _owner)
        {
            var _sx = _owner.x;
            var _sy = _owner.y - 20;
            var _tx = (_enemy.bbox_left + _enemy.bbox_right) * 0.5;
            var _ty = (_enemy.bbox_top + _enemy.bbox_bottom) * 0.5;
            if (collision_line(_sx, _sy, _tx, _ty, o_Block, false, true) != noone) continue;
            var _door = collision_line(_sx, _sy, _tx, _ty, o_Door_UNB, false, true);
            if (_door != noone && _door.door_state != 2) continue;
        }
        array_push(_targets, _enemy);
    }
    if (array_length(_targets) == 0) return noone;
    return _targets[irandom(array_length(_targets) - 1)];
}

function chip_attach_heal(_target, _amount)
{
    if (!instance_exists(_target) || _target.ehp <= 0) return false;
    if (_target.ehp >= _target.ehp_max || chip_heal_active(_target)) return false;
    var _chip = instance_create_depth(_target.x, _target.y, _target.depth - 2, o_ChipAttachment);
    _chip.target = _target;
    _chip.is_healing = true;
    _chip.heal_total = _amount;
    return true;
}

function chip_crash_enemy(_target, _amount)
{
    if (!instance_exists(_target)) return;
    // A physical crash damages health directly, including through shields.
    _target.ehp = max(0, _target.ehp - _amount);
    _target.hit_timer = _target.hit_duration;
    _target.slam_stun_timer = max(_target.slam_stun_timer, 4);
    _target.slam_interrupt();
    if (_target.ehp <= 0) with (_target) instance_destroy();
}

function chip_player_setup()
{
    chip_effect_timers = [0, 0, 0, 0, 0];
    chip_effect_durations = [5, 3, 10, 5, 4];
    chip_dot_ticks = [0, 0, 0, 0, 0];
    chip_wall_holding_now = false;
    chip_wall_release_timer = 0;
    chip_waiting_for_landing = false;
    chip_landing_stun_timer = 0;
    chip_sword_cooldown_timer = 0;

    chip_has_effect = function(_effect)
    {
        return chip_effect_timers[_effect] > 0;
    };

    chip_heal_multiplier = function()
    {
        return chip_has_effect(ChipEffect.GREEN) ? 0.5 : 1;
    };

    // Retained for the existing weapon code; these chips don't slow weapons.
    chip_attack_multiplier = function()
    {
        return 1;
    };

    chip_movement_multiplier = function()
    {
        var _remaining = chip_effect_timers[ChipEffect.YELLOW];
        // First second: stun. The following four seconds: 10% slower movement.
        return (_remaining > 0 && _remaining <= 4) ? 0.9 : 1;
    };

    chip_take_dot = function(_amount)
    {
        if (_amount <= 0 || pHP <= 0) return;
        // Deliberately bypass damage_blocks_damage() and all iFrames.
        pHP = max(0, pHP - _amount);
        global.demo_took_damage = true;
    };

    // 0 = protected, 1 = attached, 2 = both different-chip slots occupied.
    chip_receive_hit = function(_source_x, _wall_throw)
    {
        // Only the initial hit respects dash/slam protection.
        if (!take_damage(5, _source_x)) return 0;
        var _active = 0;
        var _common = [];
        for (var _i = 0; _i < 5; _i++)
        {
            if (chip_effect_timers[_i] > 0) _active++;
            else if (_i != ChipEffect.WHITE) array_push(_common, _i);
        }
        if (_wall_throw)
        {
            chip_waiting_for_landing = true;
            chip_wall_release_timer = 3;
            chip_wall_holding_now = false;
            wall_slide_active = false;
            wall_slide_speed = 0;
            is_ledge_climbing = false;
            is_mantle_lunging = false;
            is_slamming = false;
            dash_active = false;
            dash_current_speed = 0;
            dash_iframe_timer = 0;
            coyote_timer = 0;
            damage_knockback_pending = false;
            damage_knockback_timer = 0;
            // Push away from the wall; do not teleport through geometry.
            var _away = sign(_source_x - x);
            if (_away == 0) _away = -sign(image_xscale);
            if (_away == 0) _away = 1;
            phy_speed_x = _away * 3;
            phy_speed_y = max(2, phy_speed_y);
            wall_jump_forced_direction = _away;
            wall_jump_lock_time = 0.35;
        }

        if (_active >= 2) return 2;
        var _effect;
        // White gets a 1-in-10 roll if it isn't already attached.
        if (!chip_has_effect(ChipEffect.WHITE) && irandom(9) == 0)
            _effect = ChipEffect.WHITE;
        else
            _effect = _common[irandom(array_length(_common) - 1)];

        chip_effect_timers[_effect] = chip_effect_durations[_effect];
        chip_dot_ticks[_effect] = 0;
        if (_effect == ChipEffect.YELLOW)
            chip_landing_stun_timer = max(chip_landing_stun_timer, 1);

        var _chip = instance_create_depth(x, y, depth - 2, o_ChipAttachment);
        _chip.target = id;
        _chip.effect = _effect;
        _chip.duration = chip_effect_durations[_effect];
        return 1;
    };

    chip_player_tick = function()
    {
        var _dt = chip_dt();
        chip_wall_release_timer = max(0, chip_wall_release_timer - _dt);
        chip_landing_stun_timer = max(0, chip_landing_stun_timer - _dt);
        chip_sword_cooldown_timer = max(0, chip_sword_cooldown_timer - _dt);
        chip_wall_holding_now = false;

        for (var _i = 0; _i < 5; _i++)
        {
            var _previous = chip_effect_timers[_i];
            if (_previous <= 0) continue;
            var _remaining = max(0, _previous - _dt);
            chip_effect_timers[_i] = _remaining;
            var _elapsed = chip_effect_durations[_i] - _remaining;
            var _interval = 0;
            var _limit = 0;
            var _damage = 0;
            if (_i == ChipEffect.RED)
            {
                _interval = 1;
                _limit = 3;
                _damage = 5;
            }
            else if (_i == ChipEffect.ORANGE)
            {
                _interval = 0.5;
                _limit = 20;
                _damage = 1;
            }
            if (_limit > 0)
            {
                // Catch up correctly even when one frame spans multiple ticks.
                while (chip_dot_ticks[_i] < _limit
                && _elapsed + 0.000001 >= (chip_dot_ticks[_i] + 1) * _interval)
                {
                    chip_dot_ticks[_i]++;
                    chip_take_dot(_damage);
                }
            }
        }
    };

    chip_ground_update = function(_grounded)
    {
        if (chip_waiting_for_landing && _grounded)
        {
            chip_waiting_for_landing = false;
            chip_landing_stun_timer = max(chip_landing_stun_timer, 2);
            wall_jump_lock_time = 0;
            wall_jump_forced_direction = 0;
        }
        // This timer handles both yellow's immediate stun and the wall landing stun.
        if (chip_landing_stun_timer <= 0) return false;
        phy_speed_x = 0;
        if (_grounded) phy_speed_y = 0;
        is_slamming = false;
        is_ledge_climbing = false;
        is_mantle_lunging = false;
        dash_active = false;
        dash_current_speed = 0;
        dash_iframe_timer = 0;
        sword_swing_pending_hit = false;
        return true;
    };
}

function chip_draw_player_hud()
{
    var _old_color = draw_get_color();
    var _old_alpha = draw_get_alpha();
    var _old_h = draw_get_halign();
    var _old_v = draw_get_valign();
    var _names = ["HEALING -50%", "RED: DAMAGE", "ORANGE: DAMAGE", "MOVEMENT -10%", "FLASHBANG"];
    var _colors = [c_lime, c_red, make_color_rgb(255, 140, 30), c_yellow, c_white];
    draw_set_alpha(1);
    draw_set_halign(fa_right);
    draw_set_valign(fa_top);
    var _y = 20;
    for (var _i = 0; _i < 5; _i++)
    {
        if (chip_effect_timers[_i] <= 0) continue;
        var _text = _names[_i] + "  " + string_format(chip_effect_timers[_i], 1, 1) + "s";
        var _x = display_get_gui_width() - 20;
        draw_set_color(c_black);
        draw_text(_x + 1, _y + 1, _text);
        draw_set_color(_colors[_i]);
        draw_text(_x, _y, _text);
        _y += 24;
    }
    if (chip_landing_stun_timer > 0)
    {
        draw_set_color(c_yellow);
        draw_text(display_get_gui_width() - 20, _y, "STUNNED");
    }
    // Full white for 0.2 seconds, fading over the following 1.8 seconds.
    var _flash_time = chip_effect_timers[ChipEffect.WHITE];
    if (_flash_time > 0)
    {
        draw_set_color(c_white);
        draw_set_alpha(clamp(_flash_time / 1.8, 0, 1));
        draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    }
    draw_set_color(_old_color);
    draw_set_alpha(_old_alpha);
    draw_set_halign(_old_h);
    draw_set_valign(_old_v);
}
