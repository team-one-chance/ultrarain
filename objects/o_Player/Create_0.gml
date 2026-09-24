// =====================================
// MOVEMENT
// =====================================
pHP= 100;
pHP_max = 1000;
pHP = pHP_max;
dmg_cooldown = 0;

move_speed = 4.4;

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
wall_jump_y = -7;

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

movement_boost_multiplier = 1;
// =====================================
// SLAM
// =====================================

slam_speed = 8;
slam_max_speed = 40;
slam_acceleration = 1.1;

is_slamming = false;


// =====================================
// SLIDING
// =====================================

is_sliding = false;

// Sliding is 1.5 times faster than normal movement
slide_speed_multiplier = 1.8;
slide_movespeed_multiplier = 1.25;
slide_jump_speed = -7;
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
ground_check_y_offset = 4;
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
// COIN ALT FIRE
// =====================================

// Extra upward force added when tossing
coin_throw_up = 4;

// Small extra forward push
coin_throw_forward = 1.5;

// Cooldown
coin_cooldown = 0.5;
coin_throw_timer = 0;

// =====================================
// MANTLE LUNGE
// =====================================

is_mantle_lunging = false;
mantle_lunge_direction = 0;

mantle_lunge_speed = 8;
mantle_lunge_up = -6;

is_mantle_lunging = false;

// =====================================
// SLIDE DOUBLE JUMP
// =====================================

// How quickly the second jump must be pressed
slide_double_jump_window = 0.25;
slide_double_jump_timer = 0;

slide_double_jump_direction = 0;

// Immediate forward launch on second press
slide_double_jump_launch_multiplier = 2;

// Boost stages
slide_double_boost_stage = 0;
slide_double_boost_timer = 0;

slide_double_boost_stage1_duration = 2;
slide_double_boost_stage2_duration = 2;
slide_double_boost_stage3_duration = 5;

slide_double_boost_stage1_multiplier = 1.5;
slide_double_boost_stage2_multiplier = 1.33;

// =====================================
// WALL SLIDE
// =====================================

wall_slide_active = false;
wall_slide_speed = 0;

wall_slide_decel = 0.15;

// =====================================
// DASH
// =====================================

dash_speed = 6;
air_dash_speed = 3;
dash_decay = 0.1;

dash_active = false;
dash_direction = 0;

// Ground dash
dash_cooldown = 0.8;
ground_dash_cooldown_timer = 0;

// Air dash
air_dash_cooldown = 1.5;
air_dash_cooldown_timer = 0;
dash_current_speed = 0;

dash_started_moving = false;

dash_burst_timer = 0;
dash_burst_duration = 0.12;
dash_stationary_speed = 15;