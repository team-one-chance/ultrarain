

// =====================================
// MOVEMENT
// =====================================
pHP= 100;
pHP_max = 100;
pHP = pHP_max;
dmg_cooldown = 0;

move_speed = 3;

dmg_cooldown = 0;

slide_exit_timer = 0;
slide_exit_delay = 0;
// =====================================
// NORMAL JUMP
// =====================================

jump_speed = -5;


// =====================================
// WALL JUMP
// =====================================

wall_jump_x = 4;
wall_jump_y = -6;

wall_jumps_used = 0;
max_wall_jumps = 2;


// =====================================
// WALL-JUMP CONTROL LOCK
// =====================================

wall_jump_lock_time = 0;
wall_jump_lock_duration = 0.3;

wall_jump_forced_direction = 0;


// =====================================
// COYOTE TIME
// =====================================

coyote_timer = 0;
coyote_duration = 0.15;


// =====================================
// SLAM
// =====================================

slam_speed = 8;
slam_max_speed = 30;
slam_acceleration = 1.1;

is_slamming = false;


// =====================================
// SLIDING
// =====================================

is_sliding = false;

// Sliding is 1.5 times faster than normal movement
slide_speed_multiplier = 1.75;
slide_movespeed_multiplier = 1.35;
slide_jump_speed = -8;
slide_time = 4;
slide_boost_timer = 0;
// Direction of the slide
// -1 = left, 1 = right
slide_direction = 0;

// =====================================
// WEAPON SYSTEM
// =====================================

// Current weapon
weapon_type = "pistol";

// Pistol properties
pistol_damage = 20;
pistol_range = 2000;
pistol_cooldown = 0.5;
pistol_piercing = 0;

// Shooting timer
weapon_fire_timer = 0;

// Primary and alternate fire
primary_fire = false;
alt_fire = false;

// =================================
// ground detect
// =================================
ground_check_y_offset = 16;
ground_check_x_offset = 10;

// =====================================
// LEDGE CLIMB
// =====================================

is_ledge_climbing = false;

ledge_climb_timer = 0;
ledge_climb_duration = 0.18;

ledge_start_x = 0;
ledge_start_y = 0;

ledge_target_x = 0;
ledge_target_y = 0;

ledge_direction = 0;

ledge_climb_forward = 20;

// =====================================
// PLAYER AIM RIG
// =====================================

aim_angle = 0;
aim_facing = 1;

// points in s_Player for attachments
rig_neck_x = 18;
rig_neck_y = 12;

rig_shoulder_l_x = 19;
rig_shoulder_l_y = 16;

rig_shoulder_r_x = 12;
rig_shoulder_r_y = 16;

//Joint-to-Joint lengths
rig_upper_arm_length = 12;
rig_lower_arm_length = 17;

// Distance from shoulder centre to trigger grip
rig_weapon_distance = 22;

// Points inside s_Pistol
rig_support_grip_x = 3;
rig_support_grip_y = 3;

rig_muzzle_x = 10;
rig_muzzle_y = 1;