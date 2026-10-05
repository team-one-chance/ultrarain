event_inherited();
// =====================================
// GROUND MOVEMENT
// =====================================
ground_move_speed = 210;
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
hit_duration = 0.5;
hit_timer = 0;

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
climb_sprite = sEnemyClimb;



// =====================================
// SPRITES
// =====================================
attack_sprite = sEnemyAttack;
bite_sprite = sEnemyBite;
stun_sprite = sEnemyStunned;
climb_sprite = sEnemyClimb;
normal_sprite = sprite_index;
hit_sprite = sEnemy_hit;


// =====================================
// CLOSE-RANGE ROCKING /UNIQUE TO ENEMYTEMP
// If I remove this, I'll get error cause I haven't adjusted the step event
// Keep it, adjust the step for enemytemp and then move it over to temp create
// =====================================

// Enter rocking when almost directly aligned with the player.
attack_rock_enter_x_distance = 1;

// Leave rocking when the player moves this far away.
attack_rock_exit_x_distance = 90;

attack_rock_distance_min = 16;
attack_rock_distance_max = 36;

attack_rock_speed_min = 89;
attack_rock_speed_max = 125;

attack_rock_start_delay_min = 0;
attack_rock_start_delay_max = 0.25;

attack_rock_turn_delay_min = 0.05;
attack_rock_turn_delay_max = 0.25;

attack_rock_blocked_delay_min = 0.05;
attack_rock_blocked_delay_max = 0.2;

attack_rock_offset_min = -10;
attack_rock_offset_max = 10;

attack_rocking = false;
attack_rock_side = choose(-1, 1);

attack_rock_distance = random_range(
    attack_rock_distance_min,
    attack_rock_distance_max
);

attack_rock_speed = random_range(
    attack_rock_speed_min,
    attack_rock_speed_max
);

attack_rock_delay = random_range(
    attack_rock_start_delay_min,
    attack_rock_start_delay_max
);

attack_rock_offset = random_range(
    attack_rock_offset_min,
    attack_rock_offset_max
);

attack_sprite = sEnemyAttack;
bite_sprite = sEnemyBite; //unique to enemytemp, must be renamed for miniboss


// =====================================
// CHARGE ATTACK/ UNIQUE TO ENEMYTEMP
// Same Issue as above
// =====================================

// 0 = chase
// 1 = move to attack distance
// 2 = charge
// 3 = dash
// 4 = return
// 5 = stunned after parry

attack_state = 0;

attack_cooldown_min = 5;
attack_cooldown_max = 8;

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

attack_charge_duration = 0.55;
attack_dash_speed = 360;
attack_dash_overshoot = 16;
attack_return_speed = 720;

attack_shake_x_amount = 2;
attack_shake_y_amount = 1;

attack_side = choose(-1, 1);
attack_charge_timer = 0;

attack_origin_x = x;
attack_origin_y = y;
attack_target_x = x;

attack_shake_x = 0;
attack_shake_y = 0;

// SLAM TUNING
slam_knockback_multiplier = 1;
slam_knockback_duration = 0.22;
slam_stun_duration = 0.5;

slam_interrupt = function()
{
    path_end();
    is_climbing = false;
    attack_rocking = false;
    attack_shake_x = 0;
    attack_shake_y = 0;
    if (attack_state != 5) attack_state = 0;
    // Give the enemy a short pause before trying another charge.
    attack_cooldown = max(attack_cooldown, slam_stun_duration);
};