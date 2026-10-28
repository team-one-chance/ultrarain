event_inherited();

// Keep the placed miniboss body and room references; Breaker owns its movement.
enum BreakerState { CHASE, APPROACH, BASH, COOLDOWN, JUMP_CHARGE, RISE,
    SLAM_TURN, DIVE, LAND, LAND_RECOVERY, SHIELD_BREAK, STUN }
mask_index = sMiniBoss;
image_speed = 0;
// Compare standing bodies; the shield extends above Breaker's head.
var _old_centre = (bbox_left + bbox_right) * 0.5;
var _old_feet = bbox_bottom;
breaker_scale = (sprite_get_height(s_Player) + 1) * 1.5
    / sprite_get_height(s_Breaker_idle_unshielded);
image_xscale = breaker_scale;
image_yscale = breaker_scale;
x += _old_centre - (bbox_left + bbox_right) * 0.5;
y += _old_feet - bbox_bottom;
breaker_state = BreakerState.CHASE;
breaker_time = 0;
breaker_animation_time = 0;
breaker_unshielded = false;
breaker_break_pending = false;
breaker_hit_time = 0;
breaker_hit_elapsed = 0;
breaker_shield_flash_time = 0;
breaker_body_flash_time = 0;
breaker_shield_flash_duration = 0.12;
breaker_shield_flash_axis_uniform = shader_get_uniform(sh_BreakerShieldFlash, "u_shield_axis");
breaker_shield_flash_radius_uniform = shader_get_uniform(sh_BreakerShieldFlash, "u_shield_radius");
breaker_shield_flash_amount_uniform = shader_get_uniform(sh_BreakerShieldFlash, "u_flash");
breaker_body_flash_uniform = shader_get_uniform(sh_BreakerShieldFlash, "u_whole_body");
breaker_beam_knockback_distance = 0;
breaker_beam_knockback_time = 0;
breaker_control_grace = 0;
breaker_control_grace_duration = 0.75;
breaker_stun_budget = 0;
breaker_stun_elapsed = 0;
breaker_bash_hit = false;
breaker_leap_hit = false;
breaker_intercept = false;
breaker_landed = false;
facing_direction = 1;
breaker_source_direction = 1;
// Registration in the original 128x216 export canvas, before cropping.
breaker_anchor_x = 64;
breaker_anchor_y = 208;
breaker_crop_offsets = {};
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_shieldbash), [11, 118]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_block), [41, 116]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_bashcooldown), [27, 118]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_idle), [42, 118]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_jump), [39, 86]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_jumpcharge), [42, 118]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_land), [2, 83]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_landrecovery), [41, 120]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_slam), [2, 83]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_slam_trans), [3, 74]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_walk_block), [31, 118]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_walk), [31, 118]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_shieldbreak), [36, 126]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_shieldbash_unshielded), [6, 128]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_block_unshielded), [40, 126]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_bashcooldown_unshielded), [27, 130]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_idle_unshielded), [42, 128]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_jump_unshielded), [45, 104]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_jumpcharge_unshielded), [42, 128]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_land_unshielded), [5, 74]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_landrecovery_unshielded), [19, 82]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_slam_unshielded), [29, 74]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_slam_trans_unshielded), [1, 74]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_stun_unshielded), [50, 135]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_stun_enter_unshielded), [42, 128]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_stun_exit_unshielded), [42, 128]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_walk_unshielded), [32, 128]);

breaker_foot_offsets = {};
variable_struct_set(breaker_foot_offsets, sprite_get_name(s_Breaker_slam_trans), [109, 108, 106, 107, 108, 108, 108]);
variable_struct_set(breaker_foot_offsets, sprite_get_name(s_Breaker_slam_trans_unshielded), [101, 96, 96, 94, 94, 104, 115]);
variable_struct_set(breaker_foot_offsets, sprite_get_name(s_Breaker_slam), [99]);
variable_struct_set(breaker_foot_offsets, sprite_get_name(s_Breaker_slam_unshielded), [115, 115, 115]);
variable_struct_set(breaker_foot_offsets, sprite_get_name(s_Breaker_land), [99, 96, 90, 90, 94, 90]);
variable_struct_set(breaker_foot_offsets, sprite_get_name(s_Breaker_land_unshielded), [115, 105, 95, 95, 95, 95, 95, 82, 82, 82, 82]);
variable_struct_set(breaker_foot_offsets, sprite_get_name(s_Breaker_landrecovery), [88, 88, 88, 88, 88]);
variable_struct_set(breaker_foot_offsets, sprite_get_name(s_Breaker_landrecovery_unshielded), [79, 80, 81, 76, 76]);

// Shield stripe axes in cropped sprite pixels, indexed by animation frame.
breaker_shield_axes = {};
variable_struct_set(breaker_shield_axes, sprite_get_name(s_Breaker_idle), [[60.00, 3.50, 60.00, 87.50]]);
variable_struct_set(breaker_shield_axes, sprite_get_name(s_Breaker_block), [[55.00, 5.50, 55.00, 89.50], [50.18, 3.67, 60.22, 86.28], [57.50, 6.50, 58.60, 90.51], [62.00, 7.50, 62.00, 91.50]]);
variable_struct_set(breaker_shield_axes, sprite_get_name(s_Breaker_walk), [[71.00, 4.50, 71.00, 88.50], [71.00, 4.50, 71.00, 88.50], [71.00, 6.50, 71.00, 90.50], [71.00, 5.50, 71.00, 89.50], [71.00, 4.50, 71.00, 88.50], [71.00, 3.50, 71.00, 87.50], [71.00, 3.50, 71.00, 87.50], [71.00, 4.50, 71.00, 88.50], [71.00, 6.50, 71.00, 90.50], [71.00, 4.50, 71.00, 88.50], [71.00, 3.50, 71.00, 87.50], [71.00, 3.50, 71.00, 87.50]]);
variable_struct_set(breaker_shield_axes, sprite_get_name(s_Breaker_walk_block), [[65.00, 3.50, 65.00, 87.50], [63.00, 3.50, 63.00, 87.50], [64.00, 5.50, 64.00, 89.50], [64.00, 5.50, 64.00, 89.50], [65.00, 4.50, 65.00, 88.50], [64.00, 3.50, 64.00, 87.50], [63.00, 3.50, 63.00, 87.50], [65.00, 4.50, 65.00, 88.50], [64.00, 6.50, 64.00, 90.50], [63.00, 4.50, 63.00, 88.50], [62.00, 5.50, 62.00, 89.50], [64.00, 4.50, 64.00, 88.50]]);
variable_struct_set(breaker_shield_axes, sprite_get_name(s_Breaker_shieldbash), [[61.00, 3.50, 61.00, 87.50], [56.48, 5.64, 65.93, 89.20], [61.00, 6.50, 61.00, 90.50], [61.00, 6.50, 61.00, 90.50], [61.00, 6.50, 61.00, 90.50], [61.00, 6.50, 61.00, 90.50], [75.00, 5.50, 75.00, 89.50], [89.00, 4.50, 89.00, 88.50], [89.00, 5.50, 89.00, 89.50], [92.00, 5.50, 92.00, 89.50], [92.00, 5.50, 92.00, 89.50], [92.00, 5.50, 92.00, 89.50]]);
variable_struct_set(breaker_shield_axes, sprite_get_name(s_Breaker_bashcooldown), [[76.00, 5.50, 76.00, 89.50], [75.00, 4.50, 75.00, 88.50], [75.00, 3.50, 75.00, 87.50], [75.00, 3.50, 75.00, 87.50], [75.00, 3.50, 75.00, 87.50], [70.00, 4.50, 70.00, 88.50], [63.86, 88.52, 65.95, 4.50], [63.00, 4.50, 63.00, 88.50], [62.00, 3.50, 62.00, 87.50]]);
variable_struct_set(breaker_shield_axes, sprite_get_name(s_Breaker_jumpcharge), [[60.00, 3.50, 60.00, 87.50], [56.47, 5.64, 65.90, 89.32], [54.88, 4.99, 67.64, 88.24], [53.68, 6.23, 70.90, 88.85], [51.89, 6.42, 72.89, 88.64], [51.07, 7.92, 75.60, 88.18], [51.07, 7.92, 75.60, 88.18], [51.07, 7.92, 75.60, 88.18], [51.07, 7.92, 75.60, 88.18], [51.07, 7.92, 75.60, 88.18], [51.07, 7.92, 75.60, 88.18], [51.07, 7.92, 75.60, 88.18], [51.07, 7.92, 75.60, 88.18], [51.07, 7.92, 75.60, 88.18], [51.07, 9.92, 75.60, 90.18]]);
variable_struct_set(breaker_shield_axes, sprite_get_name(s_Breaker_jump), [[54.07, 41.92, 78.60, 122.18], [28.78, 15.45, 97.47, 64.20], [3.50, 6.00, 87.50, 6.00], [3.50, 6.00, 87.50, 6.00], [3.50, 6.00, 87.50, 6.00], [3.50, 6.00, 87.50, 6.00], [3.50, 6.00, 87.50, 6.00]]);
variable_struct_set(breaker_shield_axes, sprite_get_name(s_Breaker_slam_trans), [[3.50, 6.00, 87.50, 6.00], [9.53, 7.79, 93.44, 14.54], [16.94, 7.20, 99.90, 21.71], [23.69, 6.86, 105.20, 30.54], [31.67, 7.91, 109.88, 40.19], [40.07, 9.81, 114.39, 49.22], [47.51, 9.83, 116.82, 57.70]]);
variable_struct_set(breaker_shield_axes, sprite_get_name(s_Breaker_slam), [[48.51, 0.83, 117.82, 48.70]]);
variable_struct_set(breaker_shield_axes, sprite_get_name(s_Breaker_land), [[48.51, 0.83, 117.82, 48.70], [48.51, 0.83, 117.82, 48.70], [48.51, 0.83, 117.82, 48.70], [81.29, 90.43, 88.33, 6.54], [81.29, 94.43, 88.33, 10.54], [81.29, 90.43, 88.33, 6.54]]);
variable_struct_set(breaker_shield_axes, sprite_get_name(s_Breaker_landrecovery), [[70.29, 88.43, 77.33, 4.54], [69.86, 88.52, 71.95, 4.50], [68.00, 4.50, 68.00, 88.50], [66.00, 3.50, 66.00, 87.50], [62.50, 3.50, 63.60, 87.51]]);

// Existing combat tuning is retained; animation timing now controls each action.
// A deliberate chase pace; the player base run is 264 px/s.
ground_move_speed = 180;
// Approximate authored stride, scaled into room pixels.
breaker_walk_cycle_distance = 144 * breaker_scale;
normal_attack_approach_speed = ground_move_speed;
// Hard mode makes the shield-break phase a sharper escalation.
breaker_unshielded_move_multiplier = enemy_difficulty == 2 ? 1.45 : 1.2;
breaker_unshielded_damage_multiplier = enemy_difficulty == 2 ? 1.5 : 1.25;
breaker_unshielded_cooldown_multiplier = enemy_difficulty == 2 ? 0.45 : 0.6;
// The narrow core allows overlap with the outside of the visible silhouette.
breaker_body_core_fraction = 0.36;
breaker_body_height_fraction = 0.8; // Keep the feet fixed; lower the blocking top.
breaker_body_soft_margin = 12;
gravity_force = 900;
maximum_fall_speed = 500;
vertical_speed = 0;
ground_check_distance = 1;
is_grounded = false;
ehp_max = 1000;
ehp = ehp_max;
shield_hp_max = ehp_max * 0.5;
shield_hp = shield_hp_max;
shield_bar_width = 28;
shield_bar_height = 3;
shield_bar_y_offset = 12;
shield_front_bullet_multiplier = 0.10;
shield_front_sword_multiplier = 5;
shield_front_beam_multiplier = 1;
// One through four coins: very little, little, moderate, relatively large.
shield_beam_knockback_distances = [4, 12, 28, 56];
shield_beam_knockback_duration = 0.12;
phase2_bullet_damage_multiplier = 2;
phase2_sword_damage_multiplier = 1;
phase2_beam_damage_multiplier = 1;
back_damage_multiplier = 1;
hit_duration = 0.5;
hit_timer = 0;
normal_attack_damage = 12;
normal_attack_range = 36;
normal_attack_vertical_tolerance = 30;
var _breaker_wait = enemy_difficulty == 0 ? 1.25 : (enemy_difficulty == 2 ? 0.85 : 1);
normal_attack_cooldown_min = 0.6 * _breaker_wait;
normal_attack_cooldown_max = 0.9 * _breaker_wait;
normal_attack_cooldown = random_range(normal_attack_cooldown_min, normal_attack_cooldown_max);
stand_range = 85;
// Human frame numbers: damage and movement start at 7, end after 9.
breaker_bash_first_frame = 7;
breaker_bash_last_frame = 9;
breaker_bash_distance = 24;
// Compress only the six anticipation frames; keep the dash and follow-through.
breaker_bash_windup = 0.22;
leap_damage = 20;
leap_trigger_min_distance = 260;
leap_trigger_max_distance = 720;
leap_vertical_tolerance = 90;
leap_jump_speed = -560;
leap_launch_speed = leap_jump_speed;
leap_max_horizontal_speed = 520;
leap_fall_gravity_multiplier = 4;
leap_max_fall_speed = 1200;
leap_landing_range = 48;
leap_landing_height = 20;
leap_cooldown_min = 5 * _breaker_wait;
leap_cooldown_max = 7 * _breaker_wait;
leap_cooldown = 0; // Ready to punish a distant player immediately.
leap_target_x = x;
breaker_jump_charge_duration = 0.625;
breaker_intercept_range = 300;
breaker_intercept_min_height = 30;
breaker_intercept_max_height = 420;
breaker_intercept_max_jump_speed = 900;
breaker_intercept_prediction_time = 0.20;
breaker_intercept_max_lead = 80;
breaker_intercept_cooldown_duration = 2 * _breaker_wait;
breaker_intercept_cooldown = 0;
// Fit the entire turn to the apex instead of hovering for the authored duration.
breaker_turn_duration = 0.18;
breaker_land_lead = 0.08;
// Shared impact-to-chase timing; both phases play every frame within this budget.
breaker_land_duration = 0.30;
breaker_land_recovery_duration = 0.25;
slam_knockback_multiplier = 0.35;
slam_knockback_duration = 0.16;
slam_stun_duration = 0.2;
slam_shield_damage_multiplier = 1;
phase2_slam_damage_multiplier = 1;

breaker_sprite = function(_shielded, _unshielded) {
    return breaker_unshielded ? _unshielded : _shielded;
};
breaker_fps = function(_sprite) {
    if (_sprite == s_Breaker_jumpcharge || _sprite == s_Breaker_jumpcharge_unshielded)
        return max(1, sprite_get_number(_sprite)) / breaker_jump_charge_duration;
    if (_sprite == s_Breaker_land || _sprite == s_Breaker_land_unshielded)
        return max(1, sprite_get_number(_sprite)) / breaker_land_duration;
    if (_sprite == s_Breaker_landrecovery || _sprite == s_Breaker_landrecovery_unshielded)
        return max(1, sprite_get_number(_sprite)) / breaker_land_recovery_duration;
    var _fps = sprite_get_speed(_sprite);
    if (sprite_get_speed_type(_sprite) == spritespeed_framespergameframe)
        _fps *= game_get_speed(gamespeed_fps);
    if (_sprite == s_Breaker_bashcooldown_unshielded)
        _fps /= breaker_unshielded_cooldown_multiplier;
    return max(0.001, _fps);
};
breaker_duration = function(_sprite) {
    return max(1, sprite_get_number(_sprite)) / breaker_fps(_sprite);
};
breaker_set_state = function(_state) {
    breaker_state = _state;
    breaker_time = 0;
    breaker_animation_time = 0;
    breaker_hit_time = 0;
    breaker_hit_elapsed = 0;
    path_end();
    if (_state == BreakerState.BASH) breaker_bash_hit = false;
    if (_state == BreakerState.JUMP_CHARGE) breaker_leap_hit = false;
    if (_state == BreakerState.LAND) breaker_landed = false;
};
// Spawn-marker entrance: launch once, bypassing chase range and charge gates.
breaker_start_entrance_slam = function() {
    var _target = instance_nearest(x, y, o_Player);
    if (!instance_exists(_target)) return;
    breaker_clear_control();
    breaker_intercept = false;
    breaker_leap_hit = false;
    leap_target_x = _target.x;
    var _direction = sign(leap_target_x - (bbox_left + bbox_right) * 0.5);
    if (_direction != 0) facing_direction = _direction;
    leap_launch_speed = leap_jump_speed;
    vertical_speed = leap_launch_speed;
    breaker_set_state(BreakerState.RISE);
    sprite_index = breaker_sprite(s_Breaker_jump, s_Breaker_jump_unshielded);
    image_index = 0;
};
breaker_attacking = function() {
    return breaker_state == BreakerState.BASH || breaker_state == BreakerState.JUMP_CHARGE
        || breaker_airborne_attack() || breaker_state == BreakerState.LAND
        || breaker_state == BreakerState.LAND_RECOVERY;
};
breaker_airborne_attack = function() {
    return breaker_state == BreakerState.RISE || breaker_state == BreakerState.SLAM_TURN
        || breaker_state == BreakerState.DIVE;
};
breaker_contact_active = function() {
    return breaker_airborne_attack()
        || (breaker_state == BreakerState.LAND && !breaker_landed);
};
breaker_leap_damage_player = function(_target) {
    if (breaker_leap_hit || !instance_exists(_target)) return;
    breaker_leap_hit = true;
    miniboss_damage_player(_target, leap_damage);
};
breaker_clear_control = function() {
    knockback_timer = 0;
    slam_stun_timer = 0;
    slam_knockback_timer = 0;
    slam_velocity_x = 0;
    slam_velocity_y = 0;
    attack_state = 0;
    stun_timer = 0;
};
breaker_request_break = function() {
    if (breaker_unshielded || breaker_state == BreakerState.SHIELD_BREAK) return;
    breaker_break_pending = true;
    // The shield stays visually intact through the entire airborne slam and land.
    if (breaker_airborne_attack() || breaker_state == BreakerState.LAND) return;
    breaker_clear_control();
    breaker_set_state(BreakerState.SHIELD_BREAK);
};
breaker_react_to_hit = function() {
    if (breaker_unshielded && (breaker_hit_time > 0 || breaker_control_grace > 0)) return;
    if (breaker_attacking() || breaker_state == BreakerState.SHIELD_BREAK
        || breaker_state == BreakerState.STUN) return;
    var _reaction = breaker_sprite(s_Breaker_block, s_Breaker_block_unshielded);
    breaker_hit_time = breaker_duration(_reaction);
    breaker_hit_elapsed = 0;
};
breaker_move_x = function(_distance, _needs_floor) {
    var _steps = ceil(abs(_distance));
    if (_steps <= 0) return;
    var _dx = _distance / _steps;
    repeat (_steps) {
        if (place_meeting(x + _dx, y, o_Block)) break;
        if (_needs_floor && !place_meeting(x + _dx, y + ground_check_distance, o_Block)) break;
        x += _dx;
    }
};
miniboss_damage_player = function(_target, _damage) {
    if (instance_exists(_target)) _target.take_damage(_damage, x);
};

miniboss_parent_take_damage = take_damage;
take_damage = function(_damage, _knockback_dir = 0, _knockback_force = 0,
    _is_sword = false, _hit_x = undefined, _is_beam = false, _beam_coins = 1) {
    if (_damage <= 0) return;
    var _attacker_x = _hit_x;
    if (is_undefined(_attacker_x)) {
        var _player = instance_nearest(x, y, o_Player);
        if (_player != noone) _attacker_x = _player.x;
    }
    var _back = !is_undefined(_attacker_x)
        && sign(_attacker_x - (bbox_left + bbox_right) * 0.5) == -facing_direction;
    // Shield impacts and phase-two body hits share the same coin-scaled push.
    if (_is_beam && (breaker_unshielded || (shield_hp > 0 && !_back))
        && !breaker_attacking()
        && breaker_state != BreakerState.SHIELD_BREAK
        && breaker_state != BreakerState.STUN
        && place_meeting(x, y + ground_check_distance, o_Block)) {
        var _tier = clamp(floor(_beam_coins), 1, array_length(shield_beam_knockback_distances)) - 1;
        breaker_beam_knockback_distance = lengthdir_x(
            shield_beam_knockback_distances[_tier], _knockback_dir);
        breaker_beam_knockback_time = shield_beam_knockback_duration;
    }
    if (shield_hp > 0 && !_back) {
        var _mult = _is_beam ? shield_front_beam_multiplier
            : (_is_sword ? shield_front_sword_multiplier : shield_front_bullet_multiplier);
        shield_hp = max(0, shield_hp - _damage * _mult);
        breaker_shield_flash_time = breaker_shield_flash_duration;
        if (shield_hp <= 0) breaker_request_break();
        else breaker_react_to_hit();
        return;
    }
    if (shield_hp <= 0) _damage *= _is_beam ? phase2_beam_damage_multiplier
        : (_is_sword ? phase2_sword_damage_multiplier : phase2_bullet_damage_multiplier);
    if (_back) _damage *= back_damage_multiplier;
    if (breaker_unshielded && _damage > 0)
        breaker_body_flash_time = breaker_shield_flash_duration;
    breaker_react_to_hit();
    // Block reactions handle stagger; beam pushback is handled separately above.
    // Avoid invoking the parent's Scout-specific dash parry or knockback.
    miniboss_parent_take_damage(_damage, _knockback_dir, 0, false);
};
slam_interrupt = function() {
    if (!breaker_unshielded || breaker_attacking() || breaker_control_grace > 0
        || breaker_state == BreakerState.SHIELD_BREAK) {
        breaker_clear_control();
        return;
    }
    if (breaker_state != BreakerState.STUN) {
        breaker_set_state(BreakerState.STUN);
        breaker_stun_elapsed = 0;
        var _minimum = breaker_duration(s_Breaker_stun_enter_unshielded)
            + breaker_duration(s_Breaker_stun_exit_unshielded);
        slam_stun_timer = max(slam_stun_timer, _minimum);
        breaker_stun_budget = max(slam_stun_timer, max(slam_knockback_timer, stun_timer));
    }
    else {
        // External control sources cannot replenish an already active stun.
        slam_stun_timer = min(slam_stun_timer, breaker_stun_budget);
        slam_knockback_timer = min(slam_knockback_timer, breaker_stun_budget);
        stun_timer = min(stun_timer, breaker_stun_budget);
    }
};
slam_damage = function(_damage, _impact_x, _source) {
    if (_damage <= 0) return;
    var _back = sign(_impact_x - (bbox_left + bbox_right) * 0.5) == -facing_direction;
    if (shield_hp > 0 && !_back) {
        shield_hp = max(0, shield_hp - _damage * slam_shield_damage_multiplier);
        breaker_shield_flash_time = breaker_shield_flash_duration;
        if (shield_hp <= 0) breaker_request_break();
        else breaker_react_to_hit();
        return;
    }
    if (shield_hp <= 0) _damage *= phase2_slam_damage_multiplier;
    if (_back) _damage *= back_damage_multiplier;
    if (breaker_unshielded && _damage > 0)
        breaker_body_flash_time = breaker_shield_flash_duration;
    breaker_react_to_hit();
    miniboss_parent_take_damage(_damage, 0, 0, false);
};
// Shielded Breaker and active attacks take damage but resist crowd control.
take_slam = function(_damage, _speed, _impact_x, _impact_y, _source) {
    if (!breaker_unshielded || breaker_attacking() || breaker_control_grace > 0
        || breaker_state == BreakerState.STUN || breaker_state == BreakerState.SHIELD_BREAK) {
        slam_damage(max(0, _damage * slam_damage_multiplier), _impact_x, _source);
        return;
    }
    enemy_receive_slam(_damage, _speed, _impact_x, _impact_y, _source);
};
sprite_index = s_Breaker_idle;
normal_sprite = s_Breaker_idle;
stun_sprite = s_Breaker_stun_unshielded;
