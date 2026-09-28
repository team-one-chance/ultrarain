event_inherited();

// =====================================
// GROUND MOVEMENT
// =====================================

ground_move_speed = 60;
vertical_speed = 0;
gravity_force = 900;
maximum_fall_speed = 500;
ground_jump_speed = -330;
is_grounded = false;
ground_check_distance = 1;

// =====================================
// HP AND HIT EFFECT
// =====================================

ehp_max = 400;
ehp = ehp_max;

// Front hits drain the shield; hits from behind bypass it.
shield_hp_max = ehp_max * 0.5;
shield_hp = shield_hp_max;
shield_bar_width = 28;
shield_bar_height = 3;
shield_bar_y_offset = 12;

hit_duration = 0.5;
hit_timer = 0;

// =====================================
// ATTACK DISTANCES
// =====================================

attack_vertical_tolerance = 30;
attack_trigger_x_distance = 90;

// =====================================
// SPRITES
// =====================================

normal_attack_no_shield = sMiniBossAttackNoShield;
stand_sprite_no_shield = sMiniBossStandNoShield;

normal_attack = shield_hp > 0
    ? sMiniBossAttack : normal_attack_no_shield;
stun_sprite = sMiniBossStunned;
jump_sprite = sMiniBossClimb;
normal_sprite = sprite_index;
walk_sprite = normal_sprite;
stand_sprite = shield_hp > 0
    ? sMiniBossStand : stand_sprite_no_shield;
hit_sprite = sMiniBossHit;
defend_sprite = sMiniBossDefend;
hard_landing_sprite = sMiniBossHardlanding;
hard_landing_sprite_source_direction = -1; // Change to 1 if the artwork faces right

// Use one collision shape as the animation changes.
mask_index = walk_sprite;

// Direction each unflipped sprite was drawn facing.
// 1 = right, -1 = left. Adjust individual sprites if needed.
walk_sprite_source_direction = -1;
stand_sprite_source_direction = -1;
attack_sprite_source_direction = -1;
stand_no_shield_source_direction = -1;
attack_no_shield_source_direction = -1;
jump_sprite_source_direction = -1;
hit_sprite_source_direction = -1;
defend_sprite_source_direction = -1;
stun_sprite_source_direction = -1;

// =====================================
// SHIELD AND BACK DAMAGE
// =====================================

// Damage dealt to shield HP when struck from the front.
shield_front_bullet_multiplier = 0.10;
shield_front_sword_multiplier = 0.50;
shield_front_beam_multiplier = 1; // Adjust this

phase2_bullet_damage_multiplier = 3.0;
phase2_sword_damage_multiplier = 1.0;
phase2_beam_damage_multiplier = 1.0;

// Hits from behind deal 50% extra directly to the boss.
back_damage_multiplier = 1;
defend_sprite_duration = 0.30;
defend_sprite_timer = 0;
facing_direction = -1;

// Seconds before turning toward a player behind him while standing
// or performing a normal attack. Chase and leap turn immediately.
stand_attack_turn_delay = 0.1;
stand_attack_turn_timer = stand_attack_turn_delay;

// The fifth argument is optional. Pass the X position where a hit
// originated for bullets or attacks that do not come from o_Player.
miniboss_parent_take_damage = take_damage;

take_damage = function(
    _damage,
    _knockback_dir = 0,
    _knockback_force = 0,
    _is_sword = false,
    _hit_x = undefined,
	_is_beam = false
	
)
{
    var attacker_x = _hit_x;

    if (is_undefined(attacker_x))
    {
        var attacker = instance_nearest(x, y, o_Player);

        if (attacker != noone)
        {
            attacker_x = attacker.x;
        }
    }

    var front_hit = false;
    var back_hit = false;

    if (!is_undefined(attacker_x))
    {
        var body_center_x = (bbox_left + bbox_right) * 0.5;
        var hit_direction = sign(attacker_x - body_center_x);
        front_hit = hit_direction == facing_direction;
        back_hit = hit_direction == -facing_direction;
    }

    // The back is unprotected even while the shield still has HP.
    if (shield_hp > 0 && !back_hit)
    {
        var shield_damage = _damage;

        if (front_hit)
{
    if (_is_beam)
    {
        shield_damage *= shield_front_beam_multiplier;
    }
    else if (_is_sword)
    {
        shield_damage *= shield_front_sword_multiplier;
    }
    else
    {
        shield_damage *= shield_front_bullet_multiplier;
    }
}

        // The breaking hit is absorbed completely by the shield.
        shield_hp = max(0, shield_hp - shield_damage);

        if (shield_hp <= 0)
        {
            stand_sprite = stand_sprite_no_shield;
            normal_attack = normal_attack_no_shield;
        }

        show_debug_message(
            "MiniBoss shield damaged: " + string(shield_damage)
            + " | Shield HP: " + string(shield_hp)
        );

        if (front_hit && shield_hp > 0)
        {
            hit_timer = 0;
            defend_sprite_timer = defend_sprite_duration;
            sprite_index = defend_sprite;
            image_index = 0;
        }
        else
        {
            // The breaking hit uses the usual hit flash.
            defend_sprite_timer = 0;
            hit_timer = hit_duration;
            sprite_index = hit_sprite;
            image_index = 0;
        }

        // Bullets striking the shield's front do not push the boss.
        // Front sword hits keep the force supplied by the sword attack.
        if (front_hit && !_is_sword)
        {
            _knockback_force = 0;
        }

        if (_knockback_force > 0)
        {
            path_end();
            knockback_timer = knockback_duration;
            knockback_x = lengthdir_x(
                _knockback_force,
                _knockback_dir
            );
            knockback_y = lengthdir_y(
                _knockback_force,
                _knockback_dir
            );
        }

        return;
    }

    // Back hits bypass the shield; front hits reach the boss after it breaks.
defend_sprite_timer = 0;

// Phase-two multipliers apply only after the shield has broken.
if (shield_hp <= 0)
{
    if (_is_beam)
    {
        _damage *= phase2_beam_damage_multiplier;
    }
    else if (_is_sword)
    {
        _damage *= phase2_sword_damage_multiplier;
    }
    else
    {
        _damage *= phase2_bullet_damage_multiplier;
    }
}

if (back_hit)
{
    _damage *= back_damage_multiplier;
}

miniboss_parent_take_damage(
    _damage,
    _knockback_dir,
    _knockback_force,
    _is_sword
);
};

// =====================================
// NORMAL ATTACK
// =====================================

normal_attack_damage = 12;
normal_attack_range = 36;
normal_attack_vertical_tolerance = 30;
normal_attack_windup = 0.18;
normal_attack_recovery = 0.32;
normal_attack_cooldown_min = 1.2;
normal_attack_cooldown_max = 1.8;
normal_attack_cooldown = random_range(
    normal_attack_cooldown_min,
    normal_attack_cooldown_max
);

// =====================================
// WAIT / APPROACH BEFORE NORMAL ATTACK
// =====================================

stand_range = 85; // Enter pacing within this X distance.
stand_pace_distance = 12; // Pixels to either side of the entry point.
stand_pace_speed = 18; // Pixels per second while waiting.
normal_attack_approach_speed = 120; // Pixels per second once ready.

stand_pace_origin_x = x;
stand_pace_direction = choose(-1, 1);
stand_pacing = false;

// =====================================
// LEAP AND LANDING ATTACK
// =====================================

leap_damage = 20;
// Only start a leap within this horizontal range (pixels).
leap_trigger_min_distance = 95;
leap_trigger_max_distance = 220;
leap_vertical_tolerance = 90;
leap_jump_speed = -430;
leap_max_horizontal_speed = 520;
leap_fall_gravity_multiplier = 2.5;
leap_max_fall_speed = 900;
leap_landing_range = 48;
leap_landing_height = 20;
leap_recovery = 0.45;
leap_cooldown_min = 5;
leap_cooldown_max = 7;
leap_cooldown = random_range(
    leap_cooldown_min,
    leap_cooldown_max
);

// =====================================
// MINI-BOSS STATE
// =====================================

// 0 = chase / pace; 1 = normal windup; 2 = normal recovery;
// 3 = leap; 4 = landing recovery; 5 = approach for normal attack.
miniboss_state = 0;
miniboss_timer = 0;
leap_horizontal_speed = 0;
leap_target_x = x;
leap_aim_locked = false;
leap_left_ground = false;
miniboss_player_damage_warning_shown = false;

// Replace this one function if o_Player uses a different damage API.
miniboss_damage_player = function(_target, _damage)
{
    if (!instance_exists(_target))
    {
        return;
    }

    if (variable_instance_exists(_target, "take_damage"))
    {
        _target.take_damage(_damage);
    }
    else if (!miniboss_player_damage_warning_shown)
    {
        show_debug_message(
            "oMiniBoss: connect miniboss_damage_player to the player's damage code."
        );
        miniboss_player_damage_warning_shown = true;
    }
};
