timerf3 = 0;

// Keep the dev controller within GameMaker's drawable depth range.
if (!instance_exists(o_DevMenu)) instance_create_depth(0, 0, -14000, o_DevMenu);
if (!instance_exists(o_PauseMenu)) instance_create_depth(0, 0, -15000, o_PauseMenu);

// =====================================
// HEALTH
// =====================================

pHP_max = 150;
pHP = pHP_max;
dmg_cooldown = 0;

// Small damage recoil; speeds use the same units as player movement.
damage_knockback_speed = 2.5;
damage_knockback_duration = 0.12;
damage_knockback_lift = 1.5;
damage_knockback_timer = 0;
damage_knockback_speed_x = 0;
damage_knockback_pending = false;

// All attacks use this method. Pass the source's x position when available.
// Returns true only when health was actually lost.
take_damage = function(_amount, _source_x = undefined)
{
	    if (grinder_dying) return false;
    // Slam blocks the whole hit, including recoil and trap bounce.
    if (_amount <= 0 || pHP <= 0 || damage_blocks_damage()) return false;

    var _push = 0;
    if (!is_undefined(_source_x)) _push = sign(x - _source_x);
    if (_push == 0) _push = -sign(aim_facing);
    if (_push == 0) _push = -1;

    pHP = max(0, pHP - _amount);
    if (pHP > 0) audio_play_sound(sfxPTakeDamage, 1, false);
    global.demo_took_damage = true;
    damage_knockback_speed_x = _push * damage_knockback_speed;
    damage_knockback_timer = damage_knockback_duration;
    damage_knockback_pending = true;
    is_slamming = false;
    phy_speed_x = damage_knockback_speed_x;
    phy_speed_y = min(phy_speed_y, -damage_knockback_lift);
    return true;
};

// Reset on a fresh tutorial run, but preserve across the train trip.
if (room == LE_TUTORIAL_WIP)
{
    global.demo_took_damage = false;
    global.demo_used_healing = false;
}
else
{
    // Also support testing the train or ending room directly.
    if (!variable_global_exists("demo_took_damage"))
    {
        global.demo_took_damage = false;
    }

    if (!variable_global_exists("demo_used_healing"))
    {
        global.demo_used_healing = false;
    }
}

// =====================================
// COIN GUI
// =====================================
coin_max = 4;
coin_count = coin_max;

// =====================================
// MOVEMENT
// =====================================
move_speed = 4.4;

// Single footstep SFX, repeated at the running cadence.
footstep_interval = 0.28;
footstep_timer = 0;
footstep_last_x = x;

// Avoid a landing sound on spawn and track the wall-slide loop per player.
sfx_was_grounded = true;
wall_slide_sound = -1;
stop_wall_slide_sfx = function()
{
    if (wall_slide_sound != -1 && audio_is_playing(wall_slide_sound))
    {
        audio_stop_sound(wall_slide_sound);
    }
    wall_slide_sound = -1;
};

slide_sound = -1;
stop_slide_sfx = function()
{
    if (slide_sound != -1 && audio_is_playing(slide_sound))
    {
        audio_stop_sound(slide_sound);
    }
    slide_sound = -1;
};

stop_movement_sfx = function()
{
    stop_wall_slide_sfx();
    stop_slide_sfx();
};

// Limit busy scrap piles to one impact and one crushing cue at a time.
scrap_impact_sound = -1;
scrap_crush_sound = -1;
stop_scrap_sfx = function()
{
    if (scrap_impact_sound != -1) audio_stop_sound(scrap_impact_sound);
    if (scrap_crush_sound != -1) audio_stop_sound(scrap_crush_sound);
    scrap_impact_sound = -1;
    scrap_crush_sound = -1;
};

// One nearby-wire ambience loop, shared across all three wire hazard types.
electric_wires_sound = -1;
// Rooms can delay one wire group until a platform is reached and silence it at the lab.
electric_wires_delayed_object = noone;
electric_wires_activation_platform = noone;
electric_wires_lab_door = undefined;
electric_wires_lab_door_progress = undefined;
electric_wires_second_unlocked = true;
electric_wires_lab_entered = false;
electric_wires_range = 480;
electric_wires_delayed_range = 224;
electric_wires_fade_duration = 0.6;
electric_wires_fade_remaining = 0;
stop_electric_wires_sfx = function()
{
    if (electric_wires_sound != -1 && audio_is_playing(electric_wires_sound))
    {
        audio_stop_sound(electric_wires_sound);
    }
    electric_wires_sound = -1;
    electric_wires_fade_remaining = 0;
};

fade_electric_wires_sfx = function()
{
    if (electric_wires_sound != -1 && audio_is_playing(electric_wires_sound)
        && electric_wires_fade_remaining <= 0)
    {
        electric_wires_fade_remaining = electric_wires_fade_duration;
        audio_sound_gain(electric_wires_sound, 0, electric_wires_fade_duration * 1000);
    }
};

update_electric_wires_sfx = function()
{
    // Audio fades use elapsed real time, matching the audio engine's gain ramp.
    if (electric_wires_fade_remaining > 0)
    {
        electric_wires_fade_remaining = max(
            0, electric_wires_fade_remaining - max(0, delta_time / 1000000)
        );
        if (electric_wires_fade_remaining <= 0) stop_electric_wires_sfx();
    }

    if (!electric_wires_second_unlocked
        && instance_exists(electric_wires_activation_platform))
    {
        var _platform = electric_wires_activation_platform;
        var _feet_y = y + ground_check_y_offset;
        if (x >= _platform.bbox_left && x <= _platform.bbox_right
            && abs(_feet_y - _platform.bbox_top) <= 8 && phy_speed_y >= 0)
        {
            electric_wires_second_unlocked = true;
        }
    }

    if (is_struct(electric_wires_lab_door))
    {
        var _door = electric_wires_lab_door;
        var _progress = (x - _door.x) * _door.direction;
        var _crossed = is_undefined(electric_wires_lab_door_progress)
            ? true
            : (electric_wires_lab_door_progress < 0 && _progress >= 0)
                || (electric_wires_lab_door_progress >= 0 && _progress < 0);
        electric_wires_lab_door_progress = _progress;
        if (_crossed && bbox_bottom >= _door.top && bbox_top <= _door.bottom)
        {
            // Entering silences the wires; leaving restores their proximity audio.
            electric_wires_lab_entered = _progress >= 0;
        }
    }

    if (electric_wires_lab_entered)
    {
        fade_electric_wires_sfx();
        return;
    }

    var _gain = 0;
    var _wire_objects = [o_Block_wires, o_Block_wires_left, o_Block_wires_right];
    for (var _i = 0; _i < array_length(_wire_objects); _i++)
    {
        if (_wire_objects[_i] == electric_wires_delayed_object
            && !electric_wires_second_unlocked) continue;
        if (instance_exists(_wire_objects[_i]))
        {
            var _range = _wire_objects[_i] == electric_wires_delayed_object
                ? electric_wires_delayed_range : electric_wires_range;
            var _distance = distance_to_object(_wire_objects[_i]);
            _gain = max(_gain, clamp(1 - _distance / max(1, _range), 0, 1));
        }
    }

    if (_gain > 0)
    {
        if (electric_wires_sound == -1 || !audio_is_playing(electric_wires_sound))
        {
            electric_wires_sound = audio_play_sound(sfxElectricWires, 0, true, 0);
        }
        electric_wires_fade_remaining = 0;
        audio_sound_gain(electric_wires_sound, _gain * 0.4, 80);
    }
    else
    {
        fade_electric_wires_sfx();
    }
};

// Local lava ambience fades with distance from the visible lava surface.
molten_lava_sound = -1;
stop_molten_lava_sfx = function()
{
    if (molten_lava_sound != -1 && audio_is_playing(molten_lava_sound))
    {
        audio_stop_sound(molten_lava_sound);
    }
    molten_lava_sound = -1;
};

update_molten_lava_sfx = function()
{
    var _range = 320;
    var _distance = instance_exists(oMoltenLava) ? distance_to_object(oMoltenLava) : _range;
    if (_distance < _range)
    {
        if (molten_lava_sound == -1 || !audio_is_playing(molten_lava_sound))
        {
            molten_lava_sound = audio_play_sound(sfxMoltenLava, 0, true, 0);
        }
        audio_sound_gain(molten_lava_sound, clamp(1 - _distance / _range, 0, 1) * 0.4, 80);
    }
    else
    {
        stop_molten_lava_sfx();
    }
};

// Use one loop for the paired grinder banks, with volume based on proximity.
gear_grinder_sound = -1;
stop_gear_grinder_sfx = function()
{
    if (gear_grinder_sound != -1 && audio_is_playing(gear_grinder_sound))
    {
        audio_stop_sound(gear_grinder_sound);
    }
    gear_grinder_sound = -1;
};

update_gear_grinder_sfx = function()
{
    var _range = 320;
    var _distance = _range;
    var _grinders = [o_GrinderLeft, o_GrinderRight];
    for (var _i = 0; _i < array_length(_grinders); _i++)
    {
        if (instance_exists(_grinders[_i]))
        {
            _distance = min(_distance, distance_to_object(_grinders[_i]));
        }
    }
    if (_distance < _range)
    {
        if (gear_grinder_sound == -1 || !audio_is_playing(gear_grinder_sound))
        {
            gear_grinder_sound = audio_play_sound(sfxGearGrinder, 0, true, 0);
        }
        audio_sound_gain(gear_grinder_sound, clamp(1 - _distance / _range, 0, 1) * 0.5, 80);
    }
    else
    {
        stop_gear_grinder_sfx();
    }
};

// Follow the ambush after its broken door disappears, until its enemies are gone.
ambush_alarm_sound = -1;
ambush_alarm_doors = [];
ambush_alarm_enemies = [];
stop_ambush_alarm_sfx = function()
{
    if (ambush_alarm_sound != -1 && audio_is_playing(ambush_alarm_sound))
    {
        audio_stop_sound(ambush_alarm_sound);
    }
    ambush_alarm_sound = -1;
};

start_ambush_alarm_sfx = function(_door)
{
    if (instance_exists(_door)) array_push(ambush_alarm_doors, _door);
};

update_ambush_alarm_sfx = function()
{
    for (var _i = array_length(ambush_alarm_doors) - 1; _i >= 0; _i--)
    {
        if (!instance_exists(ambush_alarm_doors[_i])) array_delete(ambush_alarm_doors, _i, 1);
    }
    for (var _i = array_length(ambush_alarm_enemies) - 1; _i >= 0; _i--)
    {
        if (!instance_exists(ambush_alarm_enemies[_i])) array_delete(ambush_alarm_enemies, _i, 1);
    }

    if (array_length(ambush_alarm_doors) + array_length(ambush_alarm_enemies) > 0)
    {
        // The alarm follows the active encounter rather than filling the room.
        var _distance = 640;
        var _sources = [ambush_alarm_doors, ambush_alarm_enemies];
        for (var _group = 0; _group < array_length(_sources); _group++)
        {
            var _instances = _sources[_group];
            for (var _i = 0; _i < array_length(_instances); _i++)
                _distance = min(_distance, distance_to_object(_instances[_i]));
        }
        if (_distance >= 640)
        {
            stop_ambush_alarm_sfx();
            return;
        }
        if (ambush_alarm_sound == -1 || !audio_is_playing(ambush_alarm_sound))
        {
            ambush_alarm_sound = audio_play_sound(sfxAlarm, 1, true, 0);
        }
        audio_sound_gain(ambush_alarm_sound, (1 - _distance / 640) * 0.55, 80);
    }
    else
    {
        stop_ambush_alarm_sfx();
    }
};

slide_exit_timer = 0;
slide_exit_delay = 0;

medkit_owned = false;
syringe_count = 0;
syringe_max = 3;

use_syringe = function(_revive)
{
    if (syringe_count <= 0) return false;
    if (!_revive && (pHP <= 0 || pHP >= pHP_max)) return false;

    syringe_count -= 1;

    if (_revive)
    {
        pHP = pHP_max / 3 * chip_heal_multiplier();

        // Brief protection after revival.
        dmg_cooldown = max(dmg_cooldown, 1);
    }
    else
    {
        pHP = min(pHP_max, pHP + pHP_max / 3 * chip_heal_multiplier());
		        global.demo_used_healing = true;
    }

    audio_play_sound(sfxPHeal, 1, false);
    return true;
};

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
slam_iframe_timer = 0;
slam_impact_iframe_duration = 0.12;

// Shared protection for attacks and instant-kill hazards.
damage_blocks_damage = function()
{
    return (variable_global_exists("dev_invincible") && global.dev_invincible)
        || is_slamming || slam_iframe_timer > 0 || dash_blocks_damage();
};
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
    // Never expand an existing body into a ceiling.
    if (!_short && player_bound_fixture != -1)
    {
        if (variable_instance_exists(id, "player_can_stand"))
        {
            if (!player_can_stand()) return;
        }
    }

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
	player_collider_half_width = _half_width;
player_collider_height = _half_height * 2;
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
    player_collider_half_width = _half_width;
    player_collider_height = _half_height * 2;
    phy_fixed_rotation = true;
};

// Start with the standing collider.
player_set_collider(false);

player_can_stand = function()
{
    var _px = phy_position_x;
    var _py = phy_position_y;

    // Standing fixture:
    // 27 pixels wide, 59 tall, horizontal centre offset +0.5.
    if (collision_rectangle(
        _px - 13,
        _py - 59,
        _px + 14,
        _py - 1,
        o_Block,
        false,
        true
    ) != noone)
    {
        return false;
    }

    var _left = physics_raycast(
        _px - 12, _py - 24,
        _px - 12, _py - 60,
        o_Block, false
    );

    var _middle = physics_raycast(
        _px, _py - 24,
        _px, _py - 60,
        o_Block, false
    );

    var _right = physics_raycast(
        _px + 12, _py - 24,
        _px + 12, _py - 60,
        o_Block, false
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
gun_reticle_radius = 8;
gun_reticle_flash_duration = 0.08;
gun_reticle_flash_timer = 0;
sword_swing_timer = 0;
sword_swing_pending_hit = false;
sword_swing_facing = 1;
sword_slash_sound_index = 0;

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
rig_free_arm_slide_angle = 160; // raised behind the body when sliding right

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

dash_iframe_timer = 0;
ground_dash_iframe_duration = 0.2;
air_dash_iframe_duration = 0.38;
dash_iframe_is_ground = false;

// Call whenever an attack attempts to damage the player.
// Returns true when dash protection blocks it.
dash_blocks_damage = function()
{
    if (dash_iframe_is_ground && !dash_active)
    {
        dash_iframe_timer = 0;
        dash_iframe_is_ground = false;
    }

    // Once expired, attacks cannot restart the protection.
    if (dash_iframe_timer <= 0)
    {
        return false;
    }

    if (dash_iframe_is_ground)
    {
        // Refresh, rather than add more time.
        dash_iframe_timer = ground_dash_iframe_duration;
    }

    return true;
};

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

// =====================================
// RESTORE PLAYER
// =====================================
if (variable_global_exists("demo_travel_state"))
{
    if (is_struct(global.demo_travel_state))
    {
        var _travel = global.demo_travel_state;

        pHP_max = _travel.hp_max;
        pHP = _travel.hp;

        medkit_owned = _travel.medkit_owned;
        syringe_max = _travel.syringe_max;
        syringe_count = _travel.syringe_count;

        coin_max = _travel.coin_max;
        coin_count = _travel.coin_count;

        weapon_type = _travel.weapon_type;
        item_coin_anchor = _travel.item_coin_anchor;

        // Consume the transfer so ordinary restarts do not reuse it.
        global.demo_travel_state = undefined;
    }
}


// Chip enemy: player debuffs and wall-projectile response.
chip_player_setup();

grinder_dying = false;
grinder_elapsed = 0;
grinder_pull_duration = 0.35;
grinder_crush_duration = 0.30;

grinder_start_x = 0;
grinder_start_y = 0;
grinder_target_x = 0;
grinder_target_y = 0;
grinder_pivot_x = 0;
grinder_pivot_y = 0;
grinder_gear_depth = 0;

begin_grinder_death = function(_gear)
{
    if (grinder_dying || pHP <= 0) return;

    grinder_dying = true;
    grinder_elapsed = 0;

    grinder_start_x = x;
    grinder_start_y = y;

    // Remember the body's centre relative to its origin.
    grinder_pivot_x = (bbox_left + bbox_right) * 0.5 - x;
    grinder_pivot_y = (bbox_top + bbox_bottom) * 0.5 - y;

    var _pull_direction =
        (_gear.object_index == o_GrinderLeft) ? -1 : 1;

    grinder_target_x =
        (_gear.bbox_left + _gear.bbox_right) * 0.5
        - grinder_pivot_x
        + 32 * _pull_direction;

    grinder_target_y =
        (_gear.bbox_top + _gear.bbox_bottom) * 0.5
        - grinder_pivot_y;

    grinder_gear_depth = _gear.depth;

    // Draw the body behind the teeth as it is pulled inward.
    depth = grinder_gear_depth + 1;
    image_speed = 0;

    is_slamming = false;
    dash_active = false;
    chip_wall_holding_now = false;

    phy_speed_x = 0;
    phy_speed_y = 0;
    phy_active = false;

    global.demo_took_damage = true;
};

inventory = item_run_inventory();
// Begin/End Step snapshots let Breaker's core stop a fast dash crossing in one tick.
breaker_body_snapshot = [];
breaker_body_sides = {};

// Sweep from the torso to the aimed muzzle; do not spawn physics through terrain.
coin_spawn_at_muzzle = function()
{
    var _muzzle = player_get_muzzle();
    var _start_x = x;
    var _start_y = y - (is_sliding ? 12 : 32);
    var _distance = point_distance(_start_x, _start_y, _muzzle.muzzle_x, _muzzle.muzzle_y);
    var _steps = max(1, ceil(_distance / 2));
    var _coin_x = _start_x;
    var _coin_y = _start_y;
    for (var _i = 1; _i <= _steps; _i++)
    {
        var _next_x = lerp(_start_x, _muzzle.muzzle_x, _i / _steps);
        var _next_y = lerp(_start_y, _muzzle.muzzle_y, _i / _steps);
        if (collision_circle(_next_x, _next_y, 5, o_Block, false, true) != noone) break;
        _coin_x = _next_x;
        _coin_y = _next_y;
    }
    return instance_create_layer(_coin_x, _coin_y, "Instances", o_Coin);
};
