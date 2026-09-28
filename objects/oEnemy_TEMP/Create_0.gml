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

