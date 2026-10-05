timerf3 = 0;

// =====================================
// HEALTH
// =====================================
pHP_max = 1000;
pHP = pHP_max;
dmg_cooldown = 0;

// =====================================
// COIN GUI
// =====================================
coin_max = 4;
coin_count = coin_max;

// =====================================
// MOVEMENT
// =====================================
move_speed = 4.4;

slide_exit_timer = 0;
slide_exit_delay = 0;

// =====================================
// NORMAL JUMP
// =====================================

jump_speed = -5.2;

// =====================================
// WALL JUMP
// =====================================

wall_jump_x = 4;
wall_jump_y = -7;

left_wall_jumps_used = 0;
right_wall_jumps_used = 0;

max_wall_jumps_per_side = 2;

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
// SLAM STATE
// =====================================
is_slamming = false;
slam_distance = 0;
slam_last_y = 0;
slam_power = 1;

// =====================================
// SLAM MOVEMENT
// =====================================
slam_speed = 8;
slam_max_speed = 40;
slam_acceleration = 1.1;

// =====================================
// SLAM CHARGING
// =====================================
slam_power_double_distance = 128; // Must be greater than zero.
slam_power_max = 64;

// =====================================
// SLAM DAMAGE
// =====================================
slam_base_damage = 5;
slam_max_damage = 960;
slam_damage_power_exponent = 1;

// =====================================
// SLAM AOE (RADIUS IN PIXELS)
// =====================================
slam_base_radius = 30;
slam_max_radius = 240;
slam_radius_power_exponent = 1;

// =====================================
// SLAM KNOCKBACK (PIXELS PER SECOND)
// =====================================
slam_base_knockback_speed = 350;
slam_max_knockback_speed = 900;
slam_knockback_power_exponent = 0.5;
// =====================================
// SLAM COOLDOWN
// =====================================
slam_cooldown = 1; // Seconds between slams.
slam_cooldown_timer = 0;

// =====================================
// SLIDING
// =====================================
slide_direction = 0;
is_sliding = false;

// Sliding speed is 1.8 times normal movement.
slide_speed_multiplier = 1.8;
slide_movespeed_multiplier = 1.25;
slide_jump_speed = -8;
slide_time = 4;
slide_boost_timer = 0;
// Slide direction: -1 = left, 1 = right.

// =====================================
// DYNAMIC PLAYER COLLIDER
// =====================================

player_bound_fixture = -1;
player_collider_short = false;

player_set_collider = function(_short)
{
    if (player_bound_fixture != -1)
    {
        physics_remove_fixture(id, player_bound_fixture);
        player_bound_fixture = -1;
    }

    var _fix = physics_fixture_create();
    var _half_width;
    var _half_height;

    if (_short)
    {
        // Sliding: 59 px wide, 27 px tall.
        _half_width = 29.5;
        _half_height = 13.5;
    }
    else
    {
        // Standing: 27 px wide, 59 px tall.
        _half_width = 13.5;
        _half_height = 29.5;
    }

    physics_fixture_set_box_shape(_fix, _half_width, _half_height);
    physics_fixture_set_density(_fix, 0.5);
    physics_fixture_set_friction(_fix, 0.5);
    physics_fixture_set_restitution(_fix, 0);
    physics_fixture_set_linear_damping(_fix, 0.1);
    physics_fixture_set_angular_damping(_fix, 100);
    physics_fixture_set_collision_group(_fix, 1);
    physics_fixture_set_kinematic(_fix);

    // Keep both colliders anchored at the player's feet.
    player_bound_fixture = physics_fixture_bind_ext(
        _fix, id, 0.5, -_half_height
    );

    physics_fixture_delete(_fix);
    player_collider_short = _short;
    phy_fixed_rotation = true;
};

// Start with the standing collider.
player_set_collider(false);

player_can_stand = function()
{
    var _start_y = y - 24;
    var _end_y = y - 60;

    var _left = physics_raycast(
        x - 12, _start_y, x - 12, _end_y, o_Block, false
    );
    var _middle = physics_raycast(
        x, _start_y, x, _end_y, o_Block, false
    );
    var _right = physics_raycast(
        x + 12, _start_y, x + 12, _end_y, o_Block, false
    );

    return is_undefined(_left)
        && is_undefined(_middle)
        && is_undefined(_right);
};

// =====================================
// WEAPON SYSTEM
// =====================================

// Current weapon
weapon_type = "pistol";

// Legacy hit-knockback settings, retained for external attack scripts.
// The new slam uses slam_base_knockback_speed instead.
enemy_knock = 50;
knockback_apply = enemy_knock;

// Pistol properties
pistol_damage = 10;
pistol_range = 2000;
pistol_cooldown = 0.2;
pistol_piercing = 0;

// Shooting timer
weapon_fire_timer = 0;
sword_swing_timer = 0;
sword_swing_pending_hit = false;
sword_swing_facing = 1;

// Dark Repulsor tuning. Angles are degrees; distances are pixels;
// durations are seconds. Smaller swing_duration means a faster swing.
sword_config = {
    swing_duration: 0.30,
    hit_phase: 0.25, // 0 = swing start, 1 = swing end
    windup_phase: 0.18,
    follow_through_phase: 0.35, // how long it takes for the sword to go back up; lower is slower B)
    rest_angle: -15,
    windup_angle: 70,
    swing_arc: 200, // degrees swept toward the enemy
    swing_hand_follow: 0.55, // fraction of blade arc followed by the hilt
    swing_hand_pitch_limit: 80,
    swing_grip_retract: 8, // pull the hilt inward at the arc's ends

    grip_forward: 24,
    grip_down: 9,
    aim_pitch_limit: 60, // maximum upward/downward cursor angle
    aim_vertical_reach: 18, // vertical hilt travel in pixels
    aim_blade_follow: 0.8, // how much the blade tilts with the cursor
    support_hand_back: 2,
    support_hand_down: 6,
    main_hand_up: 3,

    slash_forward: 80, // distance from player to slash hitbox
    slash_down: 0,
    slash_scale: 1, // scales slash art and hitbox
    slash_duration: 0.15,
    slash_damage: 10,
    slash_knockback: 100
};

// Primary and alternate fire
primary_fire = false;
alt_fire = false;

// =================================
// GROUND DETECTION
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
// PLAYER AIM RIG
// =====================================

aim_rig_mode = AimRigMode.ONE_HANDED;
aim_angle = 0;
aim_facing = 1;

// Attachment points in s_Player.
rig_neck_x = 18;
rig_neck_y = 12;

rig_shoulder_l_x = 19;
rig_shoulder_l_y = 16;

rig_shoulder_r_x = 12;
rig_shoulder_r_y = 16;

// Joint-to-joint lengths.
rig_upper_arm_length = 12;
rig_lower_arm_length = 17;

// Resting position for the unused arm
rig_free_hand_offset_x = 0;
rig_free_hand_offset_y = 36;
rig_free_arm_reach = 22;
rig_free_arm_swing = 35;
rig_free_arm_phase = 0;
rig_free_arm_swing_speed = 2;
rig_free_arm_frame_hold = 1;

// Distance from shoulder centre to trigger grip
rig_weapon_distance = 28;

// Points inside s_Pistol
rig_support_grip_x = 3;
rig_support_grip_y = 3;

rig_muzzle_x = 10;
rig_muzzle_y = 1;

// =====================================
// COIN ALT FIRE
// =====================================

// Extra upward force added when tossing
coin_throw_up = 4;

// Small extra forward push
coin_throw_forward = 1.5;

// Maximum number of coins.
// Future items can increase this.
coin_max = 4;

// Start fully stocked.
coin_count = coin_max;

// Gain one coin every # seconds.
coin_recharge_time = 1.6;
coin_recharge_timer = 0;

// =====================================
// COIN SPLITSHOT
// =====================================

// Coin counts as being near its apex if its
// vertical speed is within this range.
coin_split_y_speed_threshold = 0.75;

// =====================================
// MANTLE LUNGE
// =====================================

is_mantle_lunging = false;
mantle_lunge_direction = 0;

mantle_lunge_speed = 8;
mantle_lunge_up = -6;

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
air_dash_cooldown = 1.8;
air_dash_cooldown_timer = 0;
dash_current_speed = 0;

dash_started_moving = false;

dash_burst_timer = 0;
dash_burst_duration = 0.12;
dash_stationary_speed = 15;

// =====================================
// GROUND DASH CHAIN
// =====================================

// Number of consecutive ground dashes
dash_chain = 0;

// Maximum chain
dash_chain_max = 35;

// Time allowed between dashes
dash_chain_window = 1.4;
dash_chain_timer = 0;

// Extra speed each chained dash gets
dash_chain_speed_per_dash = 0.22;

// Extra speed converted into a jump
dash_chain_jump_bonus = 0.4;

// =====================================
// PERFECT APEX FLASH
// =====================================

perfect_apex_flash_timer = 0;
perfect_apex_flash_duration = 0.15;

// =====================================
// COIN ANCHOR ITEM
// =====================================

// Player does NOT start with the item.
item_coin_anchor = false;

coin_throw_serial = 0;
pinned_coin = noone;

pinned_coin_offset_x = 42;
pinned_coin_offset_y = -48;

coin_anchor_cooldown = 8;
coin_anchor_cooldown_timer = 0;

hacking_controller = noone;
