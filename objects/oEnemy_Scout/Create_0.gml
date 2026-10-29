event_inherited();
// =====================================
// GROUND MOVEMENT
// =====================================
ground_move_speed = 300; // Base player run: 4.4 * 60 = 264 pixels/second.
vertical_speed = 0;
gravity_force = 900;
maximum_fall_speed = 500;
ground_jump_speed = -330;
is_grounded = false;

// =====================================
// HP 
// =====================================

ehp_max = 100;
ehp = ehp_max;

// =====================================
// HIT EFFECT
// =====================================
hit_duration = sprite_get_number(s_Scout_ouch) / sprite_get_speed(s_Scout_ouch);
hit_timer = 0;
scout_hit_pending = false;
scout_hit_elapsed = 0;

// =====================================
// KNOCKBACK/ GLOBAL OR UNIQUE DPENDING ON YOUR NEEDS
// =====================================
//knockback_duration = 0.2;
//knockback_move_multiplier = 0.2;
//knockback_decay = 0.8;
//knockback_timer = 0;
//knockback_x = 0;
//knockback_y = 0;

// =====================================
// WALL CLIMBING / UNIQUE TO ENEMYTEMP
// =====================================

climb_speed = 150;
climb_wall_check_distance = 2;
climb_mantle_distance = 12;
ground_check_distance = 1;

// Prevents an attack from taking control during or immediately
// after climbing. This gives the enemy time to settle on the floor.
// SHARED
post_climb_attack_delay = 0.1;
post_climb_attack_timer = 0;

is_climbing = false;
climb_direction = 0;
climb_sprite = s_Scout_climb;



// =====================================
// SPRITES
// =====================================
attack_sprite = s_Scout_charge;
bite_sprite = s_Scout_attack;
stun_sprite = s_Scout_stun;
climb_sprite = s_Scout_climb;
normal_sprite = s_Scout_idle;
hit_sprite = s_Scout_ouch;


// =====================================
// CLOSE-RANGE ATTACK
// =====================================
// Entry and damage use exact bite range; leaving range waits for the current attack cycle.
scout_bite_reach_extra = 4; // Room pixels added to the close-range attack.
// Retained name for compatibility with crowd spacing and slam interruption.
attack_rocking = false;
scout_bite_exit_after = -1; // Bite animation seconds when an out-of-range attack may finish; -1 means no pending exit.

// =====================================
// CHARGE ATTACK/ UNIQUE TO ENEMYTEMP
// Same Issue as above
// =====================================

// 0 = chase
// 1 = move to attack distance
// 2 = charge
// 3 = dash
// 4 = sliding stop
// 5 = stunned after parry

attack_state = 0;
parry_damage_multiplier = 1.5; // Sword-damage multiplier for a perfect roll parry; 1.5 means 150% of the current sword hit.
scout_ring_flash_period = 0.20; // Seconds per continuous ring pulse; lower values flash faster.
scout_ring_flash_minimum = 0.35; // Minimum ring opacity, 0-1; lower values make the pulse more pronounced.
scout_ring_clearance = 3; // Room pixels added around the artwork before ring scaling; higher values move the ring farther out.
scout_ring_time = 0; // Seconds accumulated during the roll cue, shared across charge, roll, and stopping grace.
// Per-frame visible-pixel bounds [left, top, right, bottom], in source sprite pixels.
// These keep the ring centred on the artwork as Scout steps back and curls up.
scout_ring_bounds = {};
variable_struct_set(scout_ring_bounds, sprite_get_name(s_Scout_charge), [[4,0,31,22],[5,0,29,22],[4,0,28,22],[2,0,26,22],[0,0,25,22],[0,0,25,22],[0,0,25,22],[0,0,25,22],[0,0,23,22],[0,0,23,22],[0,0,22,22],[3,0,28,22],[5,0,28,20],[9,0,28,20]]);
variable_struct_set(scout_ring_bounds, sprite_get_name(s_Scout_roll), [[1,0,17,17],[0,0,16,17],[0,0,17,17],[0,0,17,16],[0,0,17,17],[1,0,17,17],[0,1,17,17],[0,1,17,17]]);
variable_struct_set(scout_ring_bounds, sprite_get_name(s_Scout_chargeStop), [[5,0,24,20],[5,0,23,23],[5,0,27,22],[0,0,26,22],[0,0,29,22],[0,0,29,22],[0,0,29,22],[0,0,29,22],[0,0,29,22],[0,0,29,22],[0,0,29,22],[0,1,30,22],[0,0,27,23],[0,0,27,22],[0,0,27,22]]);
// Coyote time after a roll ends; normal sword collision still has to connect.
scout_parry_grace_duration = 0.15;
scout_parry_grace_timer = 0;
can_parry = function()
{
    return !is_climbing && slam_stun_timer <= 0 && slam_knockback_timer <= 0
        && (attack_state == 3 || (attack_state == 4 && scout_parry_grace_timer > 0));
};
scout_finish_roll = function()
{
    // Contact and arrival can both report the same stop in one Step.
    if (attack_state != 3) return;
    attack_state = 4;
    attack_rocking = false;
    attack_shake_x = 0;
    attack_shake_y = 0;
    scout_stop_timer = 0;
    scout_parry_grace_timer = scout_parry_grace_duration;
};

var _scout_wait = enemy_difficulty == 0 ? 1.25 : (enemy_difficulty == 2 ? 0.8 : 1);
attack_cooldown_min = 3 * _scout_wait;
attack_cooldown_max = 5 * _scout_wait;

attack_cooldown = random_range(
    attack_cooldown_min,
    attack_cooldown_max
);

attack_stop_distance_min = 55;
attack_stop_distance_max = 90;

attack_stop_distance = random_range(
    attack_stop_distance_min,
    attack_stop_distance_max
);

attack_position_tolerance = 6;

attack_charge_duration = sprite_get_number(s_Scout_charge) / sprite_get_speed(s_Scout_charge);
attack_dash_speed = 540;
scout_roll_range = 288; // Maximum centre distance for initiating a roll.
scout_roll_arrival_tolerance = 0.5; // Room pixels; avoid subpixel destination stalls.
scout_roll_timeout_grace = 0.25; // Allow brief knockback without an endless roll.
scout_roll_elapsed = 0;
scout_roll_time_limit = 0;

// Scout pressure: playback rates preserve every authored animation frame.
scout_charge_playback_rate = 1.6;
scout_charge_stop_playback_rate = 1.5; // Animation speed multiplier; higher values shorten the stop sequence and slide.
scout_charge_rate_variation_min = 0.9;
scout_charge_rate_variation_max = 1.1;
scout_charge_rate_variation = 1;
scout_melee_enter_playback_rate = 1.5;
scout_roll_prediction_time = 0.25; // Seconds of horizontal player motion to anticipate.
scout_roll_prediction_limit = 80; // Maximum lead in room pixels.
scout_group_roll_delay_min = 0.45;
scout_group_roll_delay_max = 0.75;
scout_group_roll_radius = 576;
scout_roll_spacing_timer = 0;
attack_dash_overshoot = 16;
attack_stop_slide_speed = 120; // Initial speed, easing to zero over chargeStop.
attack_miss_slide_speed = 360; // Preserve roll momentum on a miss, then ease to zero.

attack_shake_x_amount = 0;
attack_shake_y_amount = 0;

attack_side = choose(-1, 1);
attack_charge_timer = 0;

attack_origin_x = x;
attack_origin_y = y;
attack_target_x = x;

attack_shake_x = 0;
attack_shake_y = 0;

attack_shake_x = 0;
attack_shake_y = 0;

// =====================================
// SLAM TUNING
// =====================================
slam_knockback_multiplier = 1;
slam_knockback_duration = 0.22;
slam_stun_duration = 0.5;

slam_interrupt = function()
{
    scout_parry_grace_timer = 0;
    path_end();
    is_climbing = false;
    attack_rocking = false;
    attack_shake_x = 0;
    attack_shake_y = 0;
    if (attack_state != 5) attack_state = 0;
    // Give the enemy a short pause before trying another charge.
    attack_cooldown = max(attack_cooldown, slam_stun_duration);
};

// =====================================
// CROWD SPACING
// =====================================
crowd_spacing_enabled = true;

// Minimum centre spacing; collision-box widths also set a lower limit.
crowd_min_spacing = 1;

// Extra space between enemy collision boxes.
crowd_body_gap = 1;

// Pixels per second. Keep above normal chase speed (currently 300).
crowd_separation_speed = 420;

// Compare feet so enemies on different floors do not repel each other.
crowd_floor_tolerance = 12;
crowd_spacing_paused = false;

// Shared by the moving enemy and every neighbour it considers.
// Attack states, bite movement, climbing and knockback have priority.
crowd_can_separate = function()
{
    return crowd_spacing_enabled
        && attack_state == 0
        && !attack_rocking
        && !is_climbing
        && knockback_timer <= 0
        && slam_knockback_timer <= 0
        && slam_stun_timer <= 0
        && post_climb_attack_timer <= 0
        && place_meeting(
            x,
            y + ground_check_distance,
            o_Block
        );
};

// =====================================
// CHARGE CONTACT
// =====================================
attack_hit_player = false;
attack_dash_damage = 10;
attack_bite_damage = 10;
attack_bite_damage_delay = sprite_get_number(s_Scout_attackEnter) / sprite_get_speed(s_Scout_attackEnter);
attack_bite_damage_timer = 0;
scout_attack_enter_complete = false;



attack_register_dash_hit = function(_player)
{
    if (
        attack_state == 3
        && !attack_hit_player
        && instance_exists(_player)
        && place_meeting(x, y, _player)
    )
    {
        attack_hit_player = true;
		if (_player.parry_melee(id, ParryState.FULL))
    return;
        // Damage only on the first contact during the active charge attack.
        // Player protection rejects damage and recoil during dash/slam.
        _player.take_damage(attack_dash_damage, x);
        // Contact confirms the charge outcome; begin the complete stop animation.
        scout_finish_roll();
    }
};

// =====================================
// SCOUT ANIMATION
// =====================================
// Advance from gameplay time so dev speed settings affect animation too.
image_speed = 0;
sprite_index = s_Scout_idle;
// Scale both the artwork and a stable body mask. Preserve the old feet/centre.
scout_scale = 1.75;
var _old_centre = (bbox_left + bbox_right) * 0.5;
var _old_feet = bbox_bottom;
mask_index = s_Scout_idle;
image_xscale = scout_scale;
image_yscale = scout_scale;
x += _old_centre - (bbox_left + bbox_right) * 0.5;
y += _old_feet - bbox_bottom;
scout_animation_time = 0;
scout_stop_timer = 0;
scout_facing = 1;
scout_stun_elapsed = 0;
scout_was_stunned = false;
scout_roll_sound = -1;
scout_charge_sound = -1;
scout_stop_charge_sound = function()
{
    if (scout_charge_sound != -1)
    {
        audio_stop_sound(scout_charge_sound);
        scout_charge_sound = -1;
    }
};
scout_stop_roll_sound = function()
{
    if (scout_roll_sound != -1)
    {
        audio_stop_sound(scout_roll_sound);
        scout_roll_sound = -1;
    }
};
scout_walk_sounds = [sfxScoutWalk1, sfxScoutWalk2, sfxScoutWalk3, sfxScoutWalk4];
scout_footstep_index = -1;
scout_last_walk_sound_index = -1;
scout_walk_sound_repeat_count = 0;
scout_attack_sound_cycle = -1;
scout_animation_duration = function(_sprite)
{
    var _fps = sprite_get_speed(_sprite);
    if (sprite_get_speed_type(_sprite) == spritespeed_framespergameframe)
        _fps *= game_get_speed(gamespeed_fps);
    if (_sprite == s_Scout_charge)
        _fps *= scout_charge_playback_rate * scout_charge_rate_variation;
    else if (_sprite == s_Scout_chargeStop)
        _fps *= scout_charge_stop_playback_rate;
    else if (_sprite == s_Scout_attackEnter)
        _fps *= scout_melee_enter_playback_rate;
    else if (_sprite == s_Scout_walk)
        _fps *= ground_move_speed / 210;
    return sprite_get_number(_sprite) / max(0.001, _fps);
};
scout_animation_finished = function(_sprite)
{
    return sprite_index == _sprite
        && scout_animation_time >= scout_animation_duration(_sprite);
};

// Keep climbing when hit: there is no climbing hit pose to transition into.
scout_base_take_damage = take_damage;
take_damage = function(_damage, _knockback_dir = 0, _knockback_force = 0, _is_sword = false)
{
    var _hp_before = ehp;
    // Stop this Scout's roll cue immediately when the sword parries its charge.
    if (_is_sword && can_parry()) scout_stop_roll_sound();
    // Every hit restarts the reaction, including hits during ouch itself.
    // Higher-priority actions consume the hit without queuing a later reaction.
    scout_hit_pending = !is_climbing && attack_state != 3 && attack_state != 4
        && attack_state != 5 && slam_stun_timer <= 0 && slam_knockback_timer <= 0;
    scout_hit_elapsed = 0;
    hit_duration = scout_animation_duration(hit_sprite);
    if (scout_hit_pending && sprite_index == hit_sprite)
    {
        scout_animation_time = 0;
        image_index = 0;
    }
    scout_base_take_damage(_damage, _knockback_dir,
        is_climbing ? 0 : _knockback_force, _is_sword);
    if (instance_exists(id) && ehp > 0 && ehp < _hp_before
        && !(attack_state == 5 && stun_timer > 0)
        && slam_stun_timer <= 0 && slam_knockback_timer <= 0)
    {
        world_sfx_play(sfxScoutHit, x, y);
    }
};

// Match the planted bite's visible bounds, independently of animation frames.
// The same predicate controls approach, disengagement and damage.
scout_bite_in_range = function(_player)
{
    if (!instance_exists(_player)) return false;
    if (abs(_player.bbox_bottom - bbox_bottom) > attack_vertical_tolerance) return false;
    var _centre = (bbox_left + bbox_right) * 0.5;
    var _half_width = sprite_get_width(bite_sprite) * scout_scale * 0.5 + scout_bite_reach_extra;
    var _top = bbox_bottom + 1 - sprite_get_height(bite_sprite) * scout_scale;
    if (_player.bbox_right < _centre - _half_width
        || _player.bbox_left > _centre + _half_width
        || _player.bbox_bottom < _top || _player.bbox_top > bbox_bottom) return false;
    // A nearby player behind a wall cannot be bitten through it.
    return collision_line(_centre, (bbox_top + bbox_bottom) * 0.5,
        clamp(_centre, _player.bbox_left, _player.bbox_right),
        clamp((bbox_top + bbox_bottom) * 0.5, _player.bbox_top, _player.bbox_bottom),
        o_Block, false, true) == noone;
};

// Only wind up where a straight grounded roll can reach the player.
scout_can_roll_at = function(_player)
{
    if (!instance_exists(_player)) return false;
    if (abs(_player.bbox_bottom - bbox_bottom) > attack_vertical_tolerance) return false;
    var _dx = (_player.bbox_left + _player.bbox_right - bbox_left - bbox_right) * 0.5;
    if (abs(_dx) > scout_roll_range) return false;
    var _contact_distance = max(0, abs(_dx)
        - (bbox_right - bbox_left + _player.bbox_right - _player.bbox_left) * 0.5 + 1);
    // Sample the route using this Scout's full body mask, stopping at contact.
    var _steps = max(1, ceil(_contact_distance));
    for (var _i = 1; _i <= _steps; ++_i)
    {
        var _test_x = x + sign(_dx) * _contact_distance * _i / _steps;
        if (place_meeting(_test_x, y, o_Block)
            || !place_meeting(_test_x, y + ground_check_distance, o_Block)) return false;
    }
    return true;
};

// Reserve a short interval between nearby Scouts beginning their windups.
// Each instance owns its timer; no room-persistent group state is required.
scout_stagger_group_rolls = function()
{
    with (oEnemy_Scout)
    {
        if (id != other.id
            && abs(bbox_bottom - other.bbox_bottom) <= attack_vertical_tolerance
            && point_distance(x, y, other.x, other.y) <= other.scout_group_roll_radius)
        {
            scout_roll_spacing_timer = max(scout_roll_spacing_timer,
                random_range(other.scout_group_roll_delay_min, other.scout_group_roll_delay_max));
        }
    }
};
