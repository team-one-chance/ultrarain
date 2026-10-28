if (variable_instance_exists(id, "train_departing") && train_departing) {
    path_end();
    speed = 0;
    exit;
}
if (variable_global_exists("dev_freeze_enemies") && global.dev_freeze_enemies) exit;
var dt = max(0, (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) / 1000000);
path_end();
var _start_x = x;
var _previous_time = breaker_time;
breaker_time += dt;
breaker_hit_elapsed += dt;
breaker_shield_flash_time = max(0, breaker_shield_flash_time - dt);
breaker_body_flash_time = max(0, breaker_body_flash_time - dt);
breaker_control_grace = max(0, breaker_control_grace - dt);
var _was_staggered = breaker_unshielded && breaker_hit_time > 0;
breaker_hit_time = max(0, breaker_hit_time - dt);
if (_was_staggered && breaker_hit_time <= 0)
    breaker_control_grace = breaker_control_grace_duration;
hit_timer = max(0, hit_timer - dt);
normal_attack_cooldown = max(0, normal_attack_cooldown - dt);
leap_cooldown = max(0, leap_cooldown - dt);
breaker_intercept_cooldown = max(0, breaker_intercept_cooldown - dt);
var _player = instance_nearest(x, y, o_Player);
var _centre = (bbox_left + bbox_right) * 0.5;
if (_player != noone && !(breaker_intercept && breaker_contact_active())) {
    var _facing = sign(_player.x - _centre);
    if (_facing != 0) facing_direction = _facing;
}
is_grounded = place_meeting(x, y + ground_check_distance, o_Block);

// External stun sources also go through the same immunity rules.
if (attack_state == 5 || slam_stun_timer > 0 || slam_knockback_timer > 0) {
    if (attack_state == 5) slam_stun_timer = max(slam_stun_timer, stun_timer);
    slam_interrupt();
}
var _stunned = breaker_state == BreakerState.STUN;
var _stun_remaining = max(slam_stun_timer, max(slam_knockback_timer, stun_timer));
if (_stunned) {
    breaker_stun_elapsed += dt;
    enemy_slam_step(dt);
    stun_timer = max(0, stun_timer - dt);
    breaker_stun_budget = max(0, breaker_stun_budget - dt);
    if (_stun_remaining <= 0) {
        breaker_clear_control();
        breaker_set_state(BreakerState.CHASE);
        breaker_control_grace = breaker_control_grace_duration;
    }
}
// Only hit reactions outside attacks can stop unshielded movement.
var _stagger = breaker_unshielded && breaker_hit_time > 0;
var _bash = breaker_sprite(s_Breaker_shieldbash, s_Breaker_shieldbash_unshielded);
var _charge = breaker_sprite(s_Breaker_jumpcharge, s_Breaker_jumpcharge_unshielded);
var _land = breaker_sprite(s_Breaker_land, s_Breaker_land_unshielded);
var _distance = _player != noone ? abs(_player.x - _centre) : infinity;
var _feet_difference = _player != noone ? abs(_player.bbox_bottom - bbox_bottom) : infinity;
var _player_height = _player != noone ? bbox_bottom - _player.bbox_bottom : -infinity;

if (!_stunned && !_stagger) switch (breaker_state) {
    case BreakerState.CHASE:
        if (_player == noone || !is_grounded) break;
        // Let shield impacts play before starting another attack, including
        // sword hits at melee range that would otherwise clear the reaction.
        if (breaker_hit_time > 0) {
            if (_distance > stand_range)
                breaker_move_x(facing_direction * ground_move_speed * dt, true);
            break;
        }
        if (breaker_intercept_cooldown <= 0 && _distance <= breaker_intercept_range
            && _player_height > breaker_intercept_min_height
            && _player_height <= breaker_intercept_max_height) {
            breaker_intercept = true;
            leap_target_x = _player.x;
            breaker_set_state(BreakerState.JUMP_CHARGE);
        }
        else if (leap_cooldown <= 0 && _distance >= leap_trigger_min_distance
            && _distance <= leap_trigger_max_distance && _feet_difference <= leap_vertical_tolerance) {
            breaker_intercept = false;
            leap_target_x = _player.x;
            breaker_set_state(BreakerState.JUMP_CHARGE);
        }
        else if (_distance <= stand_range && _feet_difference <= normal_attack_vertical_tolerance) {
            // Stationary waiting replaces the old cooldown shuffle.
            if (normal_attack_cooldown <= 0) breaker_set_state(BreakerState.APPROACH);
        }
        else breaker_move_x(facing_direction * ground_move_speed * dt, true);
        break;

    case BreakerState.APPROACH:
        if (_player == noone || !is_grounded || _feet_difference > normal_attack_vertical_tolerance) {
            breaker_set_state(BreakerState.CHASE);
            break;
        }
        if (_distance <= normal_attack_range) {
            if (breaker_hit_time <= 0) breaker_set_state(BreakerState.BASH);
        }
        else breaker_move_x(facing_direction * normal_attack_approach_speed * dt, true);
        break;

    case BreakerState.BASH:
        var _fps = breaker_fps(_bash);
        var _authored_windup = (breaker_bash_first_frame - 1) / _fps;
        var _active_start = breaker_bash_windup;
        var _active_end = _active_start + (breaker_bash_last_frame - breaker_bash_first_frame + 1) / _fps;
        if (_previous_time < _active_start && breaker_time >= _active_start) {
            world_sfx_play(breaker_unshielded ? sfxBreakerStabAttack : sfxBreakerShieldAttack, x, y);
        }
        // Integrate just the part of this Step inside frames 7 through 9.
        var _active_dt = max(0, min(breaker_time, _active_end) - max(_previous_time, _active_start));
        if (_active_dt > 0) {
            var _dash_distance = breaker_bash_distance * _active_dt / (_active_end - _active_start);
            var _steps = max(1, ceil(_dash_distance));
            repeat (_steps) {
                breaker_move_x(facing_direction * _dash_distance / _steps, true);
                if (!breaker_bash_hit) {
                    var _left = facing_direction > 0 ? bbox_left : bbox_left - normal_attack_range;
                    var _right = facing_direction > 0 ? bbox_right + normal_attack_range : bbox_right;
                    var _target = collision_rectangle(_left, bbox_top, _right, bbox_bottom, o_Player, false, true);
                    if (_target != noone) {
                        breaker_bash_hit = true;
                        miniboss_damage_player(_target, normal_attack_damage);
                    }
                }
            }
        }
        if (breaker_time >= breaker_duration(_bash) - _authored_windup + breaker_bash_windup) {
            normal_attack_cooldown = random_range(normal_attack_cooldown_min, normal_attack_cooldown_max);
            breaker_set_state(BreakerState.COOLDOWN);
        }
        break;

    case BreakerState.COOLDOWN:
        if (breaker_hit_time <= 0
            && breaker_time >= breaker_duration(breaker_sprite(s_Breaker_bashcooldown, s_Breaker_bashcooldown_unshielded)))
            breaker_set_state(BreakerState.CHASE);
        break;

    case BreakerState.JUMP_CHARGE:
        if (_player != noone) leap_target_x = _player.x;
        if (breaker_time >= breaker_duration(_charge)) {
            leap_launch_speed = leap_jump_speed;
            if (breaker_intercept && _player != noone) {
                // Reach higher walljumps without changing the normal slam arc.
                var _height = max(0, bbox_bottom - _player.bbox_bottom) + 24;
                leap_launch_speed = -clamp(sqrt(2 * gravity_force * _height),
                    abs(leap_jump_speed), breaker_intercept_max_jump_speed);
                // Physics speed is in pixels per game frame; lead is bounded.
                leap_target_x += clamp(_player.phy_speed_x * game_get_speed(gamespeed_fps)
                    * breaker_intercept_prediction_time,
                    -breaker_intercept_max_lead, breaker_intercept_max_lead);
                var _launch_facing = sign(leap_target_x - _centre);
                if (_launch_facing != 0) facing_direction = _launch_facing;
            }
            vertical_speed = leap_launch_speed;
            breaker_set_state(BreakerState.RISE);
        }
        break;

    case BreakerState.RISE:
        if (!breaker_intercept && _player != noone) leap_target_x = _player.x;
        // Start the turn just before the apex; finish it just after the apex.
        if (vertical_speed >= -gravity_force * breaker_turn_duration * 0.5)
            breaker_set_state(BreakerState.SLAM_TURN);
        break;

    case BreakerState.SLAM_TURN:
        if (breaker_time >= breaker_turn_duration) breaker_set_state(BreakerState.DIVE);
        break;

    case BreakerState.DIVE:
        // Probe the actual floor under the body, including platforms and slopes.
        var _lookahead = max(1, ceil(max(0, vertical_speed) * breaker_land_lead
            + 0.5 * gravity_force * leap_fall_gravity_multiplier * sqr(breaker_land_lead)));
        for (var _probe = 1; _probe <= _lookahead; _probe++) {
            if (place_meeting(x, y + _probe, o_Block)) {
                breaker_set_state(BreakerState.LAND);
                break;
            }
        }
        break;

    case BreakerState.LAND:
        if (breaker_landed && breaker_time >= breaker_duration(_land)) {
            if (breaker_break_pending) {
                breaker_clear_control();
                breaker_set_state(BreakerState.SHIELD_BREAK);
            }
            else breaker_set_state(BreakerState.LAND_RECOVERY);
        }
        break;

    case BreakerState.LAND_RECOVERY:
        if (breaker_time >= breaker_duration(breaker_sprite(s_Breaker_landrecovery, s_Breaker_landrecovery_unshielded)))
            breaker_set_state(BreakerState.CHASE);
        break;

    case BreakerState.SHIELD_BREAK:
        if (breaker_time >= breaker_duration(s_Breaker_shieldbreak)) {
            breaker_break_pending = false;
            breaker_unshielded = true;
            ground_move_speed *= breaker_unshielded_move_multiplier;
            normal_attack_approach_speed *= breaker_unshielded_move_multiplier;
            leap_max_horizontal_speed *= breaker_unshielded_move_multiplier;
            breaker_bash_distance *= breaker_unshielded_move_multiplier;
            normal_attack_damage *= breaker_unshielded_damage_multiplier;
            leap_damage *= breaker_unshielded_damage_multiplier;
            normal_attack_cooldown_min *= breaker_unshielded_cooldown_multiplier;
            normal_attack_cooldown_max *= breaker_unshielded_cooldown_multiplier;
            normal_attack_cooldown *= breaker_unshielded_cooldown_multiplier;
            leap_cooldown_min *= breaker_unshielded_cooldown_multiplier;
            leap_cooldown_max *= breaker_unshielded_cooldown_multiplier;
            leap_cooldown *= breaker_unshielded_cooldown_multiplier;
            breaker_set_state(BreakerState.CHASE);
        }
        break;
}

// Apply beam pushback in either phase over a short, frame-rate independent interval.
if (breaker_beam_knockback_time > 0) {
    var _push_dt = min(dt, breaker_beam_knockback_time);
    var _push = breaker_beam_knockback_distance * _push_dt / breaker_beam_knockback_time;
    if (!breaker_attacking() && !_stunned
        && place_meeting(x, y + ground_check_distance, o_Block)) {
        breaker_move_x(_push, true);
    }
    breaker_beam_knockback_distance -= _push;
    breaker_beam_knockback_time = max(0, breaker_beam_knockback_time - _push_dt);
}

if (breaker_airborne_attack() && !_stunned) {
    breaker_move_x(clamp(leap_target_x - (bbox_left + bbox_right) * 0.5,
        -leap_max_horizontal_speed * dt, leap_max_horizontal_speed * dt), false);
}
// Breaker owns gravity so parent chase/jump/parry code cannot override an action.
var _falling_slam = breaker_state == BreakerState.DIVE || breaker_state == BreakerState.LAND;
var _gravity = gravity_force * (_falling_slam ? leap_fall_gravity_multiplier : 1);
var _fall_cap = _falling_slam ? leap_max_fall_speed : maximum_fall_speed;
is_grounded = place_meeting(x, y + ground_check_distance, o_Block);
if (is_grounded && vertical_speed >= 0) vertical_speed = 0;
else vertical_speed = min(_fall_cap, vertical_speed + _gravity * dt);
var _dy = vertical_speed * dt;
var _vertical_steps = ceil(abs(_dy));
if (_vertical_steps > 0) {
    var _pixel_y = _dy / _vertical_steps;
    repeat (_vertical_steps) {
        if (place_meeting(x, y + _pixel_y, o_Block)) {
            vertical_speed = 0;
            break;
        }
        y += _pixel_y;
    }
}
is_grounded = place_meeting(x, y + ground_check_distance, o_Block);
if (is_grounded && vertical_speed >= 0 && (breaker_airborne_attack()
    || (breaker_state == BreakerState.LAND && !breaker_landed))) {
    if (breaker_state != BreakerState.LAND) breaker_set_state(BreakerState.LAND);
    breaker_landed = true;
    world_sfx_play(sfxBreakerSlam, x, y);
    // Shared boss VFX (visual effects) reads its global settings; rooms supply no tuning overrides.
    instance_create_depth((bbox_left + bbox_right) * 0.5,
        bbox_bottom + 1, clamp(depth - 2, -15999, 15999), oBreakerSlamVFX);
    breaker_time = 0; // The landing animation progresses only after actual impact.
    vertical_speed = 0;
    leap_cooldown = random_range(leap_cooldown_min, leap_cooldown_max);
    breaker_intercept_cooldown = breaker_intercept_cooldown_duration;
    var _landing_target = collision_rectangle(bbox_left - leap_landing_range,
        bbox_bottom - leap_landing_height, bbox_right + leap_landing_range,
        bbox_bottom + ground_check_distance, o_Player, false, true);
    if (_landing_target != noone) breaker_leap_damage_player(_landing_target);
}

var _sprite = breaker_sprite(s_Breaker_idle, s_Breaker_idle_unshielded);
var _anim_time = breaker_time;
var _loop = false;
var _duration_override = 0;
switch (breaker_state) {
    case BreakerState.CHASE:
    case BreakerState.APPROACH:
        _loop = true;
        if (abs(x - _start_x) > 0.001) _sprite = breaker_sprite(s_Breaker_walk, s_Breaker_walk_unshielded);
        if (breaker_hit_time > 0) {
            _sprite = breaker_unshielded ? s_Breaker_block_unshielded
                : (abs(x - _start_x) > 0.001 ? s_Breaker_walk_block : s_Breaker_block);
            _anim_time = breaker_hit_elapsed;
            _loop = _sprite == s_Breaker_walk_block;
        }
        break;
    case BreakerState.BASH:
        _sprite = _bash;
        var _windup_time = (breaker_bash_first_frame - 1) / breaker_fps(_bash);
        _anim_time = breaker_time < breaker_bash_windup
            ? breaker_time * _windup_time / breaker_bash_windup
            : _windup_time + breaker_time - breaker_bash_windup;
        break;
    case BreakerState.COOLDOWN:
        _sprite = breaker_sprite(s_Breaker_bashcooldown, s_Breaker_bashcooldown_unshielded);
        if (breaker_hit_time > 0) {
            _sprite = breaker_sprite(s_Breaker_block, s_Breaker_block_unshielded);
            _anim_time = breaker_hit_elapsed;
        }
        break;
    case BreakerState.JUMP_CHARGE: _sprite = _charge; break;
    case BreakerState.RISE:
        _sprite = breaker_sprite(s_Breaker_jump, s_Breaker_jump_unshielded);
        _duration_override = max(0.001, -leap_launch_speed / gravity_force - breaker_turn_duration * 0.5);
        break;
    case BreakerState.SLAM_TURN:
        _sprite = breaker_sprite(s_Breaker_slam_trans, s_Breaker_slam_trans_unshielded);
        _duration_override = breaker_turn_duration;
        break;
    case BreakerState.DIVE: _sprite = breaker_sprite(s_Breaker_slam, s_Breaker_slam_unshielded); break;
    case BreakerState.LAND:
        _sprite = _land;
        if (!breaker_landed) _anim_time = 0;
        break;
    case BreakerState.LAND_RECOVERY:
        _sprite = breaker_sprite(s_Breaker_landrecovery, s_Breaker_landrecovery_unshielded); break;
    case BreakerState.SHIELD_BREAK: _sprite = s_Breaker_shieldbreak; break;
    case BreakerState.STUN:
        var _exit_time = breaker_duration(s_Breaker_stun_exit_unshielded);
        var _enter_time = breaker_duration(s_Breaker_stun_enter_unshielded);
        if (_stun_remaining <= _exit_time) {
            _sprite = s_Breaker_stun_exit_unshielded;
            _anim_time = max(0, _exit_time - _stun_remaining);
        }
        else if (breaker_stun_elapsed < _enter_time) {
            _sprite = s_Breaker_stun_enter_unshielded;
            _anim_time = breaker_stun_elapsed;
        }
        else {
            _sprite = s_Breaker_stun_unshielded;
            _anim_time = breaker_stun_elapsed - _enter_time;
            _loop = true;
        }
        break;
}
// Locomotion gets its own clock; one-shot states use time since entry.
if (_loop && breaker_state != BreakerState.STUN) {
    var _walking = _sprite == s_Breaker_walk || _sprite == s_Breaker_walk_unshielded
        || _sprite == s_Breaker_walk_block;
    var _was_walking = sprite_index == s_Breaker_walk || sprite_index == s_Breaker_walk_unshielded
        || sprite_index == s_Breaker_walk_block;
    if (_walking) {
        // Walk and walk_block share leg frames and a distance-driven phase.
        if (!_was_walking) breaker_animation_time = 0;
        breaker_animation_time += abs(x - _start_x) / breaker_walk_cycle_distance * breaker_duration(_sprite);
    }
    else if (sprite_index != _sprite) breaker_animation_time = 0;
    else breaker_animation_time += dt;
    _anim_time = breaker_animation_time;
}
sprite_index = _sprite;
var _frames = max(1, sprite_get_number(_sprite));
var _duration = _duration_override > 0 ? _duration_override : breaker_duration(_sprite);
var _frame = floor(max(0, _anim_time) * _frames / _duration);
// Two planted steps per walk cycle, following the distance-driven leg phase.
var _walking_sound = _sprite == s_Breaker_walk || _sprite == s_Breaker_walk_unshielded
    || _sprite == s_Breaker_walk_block;
if (_walking_sound && is_grounded && abs(x - _start_x) > 0.001) {
    var _footstep = floor(max(0, _anim_time) * 2 / _duration);
    if (_footstep != breaker_footstep_index) {
        world_sfx_play(sfxBreakerWalk, x, y);
        breaker_footstep_index = _footstep;
    }
}
else breaker_footstep_index = -1;
image_index = _loop ? _frame mod _frames : min(_frames - 1, _frame);
image_speed = 0;
