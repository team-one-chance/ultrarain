event_inherited()

// =====================================
// COMBAT MOVEMENT
// =====================================
drone_engaged = false;
orbit_angle = irandom(359);
orbit_direction = choose(-1, 1);
orbit_speed = 140;
orbit_radius_x = 110;
orbit_radius_y = 45;
orbit_height = 110;
orbit_change_timer = random_range(1.2, 2.4);

// =====================================
// CHASE MOVEMENT
// =====================================
chase_angle = irandom(359);
chase_direction = choose(-1, 1);
chase_pattern_speed = 150;
chase_radius_x = 80;
chase_radius_y = 35;
chase_change_timer = random_range(0.8, 1.8);

// =====================================
// HIT EFFECT IS UNIQUE
// =====================================
hit_timer = 0;
hit_duration = 0.5;
normal_sprite = sprite_index;
hit_sprite = sDrone_hit;
shoot_timer = 0;
shoot_cooldown = 0.5;

// =====================================
// HP
// =====================================
ehp_max = 100;
ehp = ehp_max;

// =====================================
// KNOCKBACK/ GLOBAL OR UNIQUE DPENDING ON YOUR NEEDS
// =====================================
//knockback_duration = 0.2;
//knockback_move_multiplier = 0.2;
//knockback_decay = 0.8;
//knockback_timer = 0;
//knockback_x = 0;
//knockback_y = 0;
