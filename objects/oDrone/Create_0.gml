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

normal_sprite = sprite_index;
hit_sprite = sEnemy_hit;
shoot_timer = 0;
shoot_cooldown = 1.5;
