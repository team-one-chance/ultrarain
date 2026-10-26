// Track actual movement so pushing against a wall does not make footsteps.
gun_reticle_flash_timer = max(0, gun_reticle_flash_timer
    - (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) / 1000000);

var _footstep_moved = abs(x - footstep_last_x) > 0.1;
footstep_last_x = x;

// Ignore menu-closing inputs for this frame; the controller clears this each Begin Step.
if (variable_global_exists("dev_resume_input") && global.dev_resume_input)
{
    stop_movement_sfx();
    exit;
}

// WASD controls only the camera while freecam is active.
if (variable_global_exists("dev_freecam") && global.dev_freecam)
{
    stop_movement_sfx();
    phy_speed_x = 0;
    phy_speed_y = 0;
    exit;
}

chip_player_tick();

if (grinder_dying)
{
    stop_movement_sfx();
    update_gear_grinder_sfx();
    var _dt = (
        variable_global_exists("dev_delta_time")
        ? global.dev_delta_time
        : delta_time
    ) / 1000000;

    grinder_elapsed += _dt;

    var _pull = clamp(
        grinder_elapsed / grinder_pull_duration,
        0, 1
    );

    _pull = _pull * _pull * (3 - 2 * _pull);

    phy_position_x = lerp(
        grinder_start_x, grinder_target_x, _pull
    );

    phy_position_y = lerp(
        grinder_start_y, grinder_target_y, _pull
    );

    if (grinder_elapsed >=
        grinder_pull_duration + grinder_crush_duration)
    {
        // Let the existing Destroy event produce the explosion.
        depth = grinder_gear_depth - 1;
        pHP = 0;
        instance_destroy();
    }

    exit;
}

// Resolve lethal hits before interaction locks or healing can skip death.
if (pHP <= 0)
{
    instance_destroy();
    exit;
}

update_electric_wires_sfx();
update_molten_lava_sfx();
update_gear_grinder_sfx();
update_ambush_alarm_sfx();

slam_iframe_timer = max(0, slam_iframe_timer - (variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000);

slam_cooldown_timer = max(
    0,
    slam_cooldown_timer - (variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000
);

dash_iframe_timer = max(
    0,
    dash_iframe_timer - (variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000
);

// =====================================
// KEEP PLAYER UPRIGHT
// =====================================

phy_fixed_rotation = true;

// =====================================
// o_Door exit
// =====================================
if (hacking_controller != noone)
{
    stop_movement_sfx();
    footstep_timer = 0;
    phy_speed_x = 0;

    var _ground_y = y + ground_check_y_offset;

    var _grounded =
        collision_point(
            x - ground_check_x_offset,
            _ground_y,
            o_Block, false, true
        ) != noone
        ||
        collision_point(
            x + ground_check_x_offset,
            _ground_y,
            o_Block, false, true
        ) != noone;

    var _sprite = _grounded ? s_Player : s_Player_Air;

    if (sprite_index != _sprite)
    {
        sprite_index = _sprite;
        image_index = 0;
    }

    image_speed = _grounded ? 0 : 1;

    exit;
}

// =====================================
// ACTIVE SPEED BOOST
// =====================================

var _chip_move_speed = move_speed * chip_movement_multiplier();

var speed_boost_multiplier = 1;

// Normal post-slide boost
if (slide_boost_timer > 0)
{
    speed_boost_multiplier = 1.15;
}

// Slide double jump - stage 1
if (slide_double_boost_stage == 1)
{
    speed_boost_multiplier = 1.25;
}

// Slide double jump - stage 2
if (slide_double_boost_stage == 2)
{
    speed_boost_multiplier = 1.2;
}


// =====================================
// GROUND DETECTION
// =====================================

var ground_y = y + ground_check_y_offset;

var ground_left =
    collision_point(
        x - ground_check_x_offset,
        ground_y,
        o_Block,
        false,
        true
    ) != noone;

var ground_right =
    collision_point(
        x + ground_check_x_offset,
        ground_y,
        o_Block,
        false,
        true
    ) != noone;

var on_ground = ground_left || ground_right;

// Only the airborne-to-grounded transition plays a normal landing sound.
if (on_ground && !sfx_was_grounded && phy_speed_y >= 0
    && !is_slamming && !is_ledge_climbing && !is_mantle_lunging)
{
    audio_play_sound(sfxLandingNoSlam, 1, false);
}
sfx_was_grounded = on_ground;

// The thrown chip starts its two-second stun on landing.
if (chip_ground_update(on_ground))
{
    stop_movement_sfx();
    footstep_timer = 0;
    exit;
}

if (on_ground)
{
    air_dash_cooldown_timer = 0;
}


// =====================================
// WALL / LEDGE DETECTION
// =====================================

// Lower body point
var left_wall_lower =
    collision_point(
        x - 15,
        y,
        o_Block,
        false,
        true
    );

// Middle
var left_wall_mid =
    collision_point(
        x - 15,
        y - 24,
        o_Block,
        false,
        true
    );

// Upper body / hand point
var left_wall_upper =
    collision_point(
        x - 15,
        y - 59,
        o_Block,
        false,
        true
    );


// Right side
var right_wall_lower =
    collision_point(
        x + 15,
        y,
        o_Block,
        false,
        true
    );

// Middle
var right_wall_mid =
    collision_point(
        x + 15,
        y - 24,
        o_Block,
        false,
        true
    );

// Upper
var right_wall_upper =
    collision_point(
        x + 15,
        y - 59,
        o_Block,
        false,
        true
    );


// =====================================
// NORMAL WALL DETECTION
// =====================================

var touching_left_wall = (left_wall_lower || left_wall_mid || left_wall_upper );
    /*(left_wall_lower != noone && left_wall_upper != noone)
    ||
    (left_wall_lower != noone && left_wall_mid != noone)
    ||
    (left_wall_upper != noone && left_wall_mid != noone)
	||
	(left_wall_upper != noone);*/

var touching_right_wall = (right_wall_lower || right_wall_mid || right_wall_upper );
    /*(right_wall_lower != noone && right_wall_upper != noone)
    ||
    (right_wall_lower != noone && right_wall_mid != noone)
    ||
    (right_wall_upper != noone && right_wall_mid != noone)
	||
	(right_wall_upper != noone);*/

// A thrown chip temporarily prevents regrabbing or wall jumping.
if (chip_wall_release_timer > 0 || chip_waiting_for_landing)
{
    touching_left_wall = false;
    touching_right_wall = false;
}

var touching_wall =
    touching_left_wall
    || touching_right_wall;

// =====================================
// LEDGE DETECTION
// =====================================

var left_ledge = false;
var right_ledge = false;

var left_ledge_top = 0;
var right_ledge_top = 0;


// LEFT
if (left_wall_lower != noone
&& left_wall_upper == noone)
{
    var left_block = left_wall_lower;

    if (left_wall_mid != noone
    && left_wall_mid.bbox_top < left_block.bbox_top)
    {
        left_block = left_wall_mid;
    }

    left_ledge_top = left_block.bbox_top;

    if (y - 64 <= left_ledge_top)
    {
        left_ledge = true;
    }
}


// RIGHT
if (right_wall_lower != noone
&& right_wall_upper == noone)
{
    var right_block = right_wall_lower;

    if (right_wall_mid != noone
    && right_wall_mid.bbox_top < right_block.bbox_top)
    {
        right_block = right_wall_mid;
    }

    right_ledge_top = right_block.bbox_top;

    if (y - 64 <= right_ledge_top)
    {
        right_ledge = true;
    }
}

if (chip_wall_release_timer > 0 || chip_waiting_for_landing)
{
    left_ledge = false;
    right_ledge = false;
}


// =====================================
// COYOTE TIME
// =====================================

// Only refresh coyote time while actually
// grounded and NOT moving upward.
//
// This prevents a normal jump from creating
// a second coyote jump.
if (on_ground && phy_speed_y >= 0)
{
    coyote_timer = coyote_duration;
}
else
{
    coyote_timer -= (variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000;

    if (coyote_timer < 0)
    {
        coyote_timer = 0;
    }
}


// =====================================
// RESET WALL JUMPS ON GROUND
// =====================================

if (on_ground)
{
    left_wall_jumps_used = 0;
    right_wall_jumps_used = 0;
}

// =====================================
// HORIZONTAL INPUT
// =====================================

var move = 0;

if (keyboard_check(vk_right)
|| keyboard_check(ord("D")))
{
    move += 1;
}

if (keyboard_check(vk_left)
|| keyboard_check(ord("A")))
{
    move -= 1;
}


// =====================================
// MANTLE INPUT
// =====================================

var mantle_held =
    keyboard_check(ord("W")); 


// =====================================
// AUTOMATIC LEDGE CLIMB START
// =====================================

if (!on_ground
&& !is_ledge_climbing
&& !is_sliding
&& wall_jump_lock_time <= 0
&& coyote_timer <= 0)
{
    var _mantle_direction = 0;
    var _mantle_block = noone;
    var _mantle_floor = 0;

    if (left_ledge && move < 0)
    {
        _mantle_direction = -1;
        _mantle_block = left_block;
        _mantle_floor = left_ledge_top;
    }
    else if (right_ledge && move > 0)
    {
        _mantle_direction = 1;
        _mantle_block = right_block;
        _mantle_floor = right_ledge_top;
    }

    if (instance_exists(_mantle_block))
    {
        // Preserve the normal mantle destination by default.
        var _target_x = phy_position_x
            + _mantle_direction * ledge_climb_forward;

        var _target_y =
            _mantle_floor - ground_check_y_offset;

        var _vent_entry = false;

        var _entrance_edge = _mantle_direction > 0
            ? _mantle_block.bbox_left
            : _mantle_block.bbox_right;

        // Search inward for a supported position where the ENTIRE
        // 59 x 27 slide body fits. Stop at the first clear position.
        for (var _inset = 31; _inset <= 96; _inset++)
        {
            var _test_x = _entrance_edge
                + _mantle_direction * _inset;

            // Feet sit one pixel above the platform.
            var _test_y = _mantle_floor - 1;

            // Match the fixture's actual horizontal offset of +0.5.
            var _short_clear = collision_rectangle(
                _test_x - 29,
                _test_y - 27,
                _test_x + 30,
                _test_y,
                o_Block,
                false,
                true
            ) == noone;

            var _supported = collision_point(
                _test_x,
                _mantle_floor + 1,
                o_Block,
                false,
                true
            ) != noone;

            if (!_short_clear || !_supported) continue;

            var _standing_blocked = collision_rectangle(
                _test_x - 13,
                _test_y - 59,
                _test_x + 14,
                _test_y - 28,
                o_Block,
                false,
                true
            ) != noone;

            if (_standing_blocked)
            {
                _vent_entry = true;
                _target_x = _test_x;
                _target_y = _test_y;
            }

            break;
        }

        is_ledge_climbing = true;
        ledge_direction = _mantle_direction;
        ledge_climb_timer = 0;

        ledge_start_x = phy_position_x;
        ledge_start_y = phy_position_y;

        ledge_target_x = _target_x;
        ledge_target_y = _target_y;

        if (_vent_entry)
        {
            player_set_collider(true);
        }

        phy_speed_x = 0;
        phy_speed_y = 0;

        is_slamming = false;
        is_sliding = false;
        is_mantle_lunging = false;

        slide_direction = 0;
        slide_exit_timer = 0;
        image_index = 0;
    }
}



// =====================================
// AUTOMATIC LEDGE CLIMB MOVEMENT
// =====================================

if (is_ledge_climbing)
{
    // Check headroom at the mantle destination before moving there.
    var _mantle_needs_slide = collision_rectangle(
        ledge_target_x - 13,
        ledge_target_y - 59,
        ledge_target_x + 13,
        ledge_target_y - 28,
        o_Block,
        false,
        true
    ) != noone;

    if (_mantle_needs_slide && !player_collider_short)
    {
        player_set_collider(true);
    }

    // Prevent normal movement from pulling us down
    phy_speed_x = 0;
    phy_speed_y = 0;

    ledge_climb_timer +=
        (variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000;


    var climb_progress =
        ledge_climb_timer
        / ledge_climb_duration;

    climb_progress =
        clamp(climb_progress, 0, 1);


    // =================================
    // PHASE 1 - MOVE UP
    // =================================

    if (climb_progress < 0.6)
    {
        var up_progress =
            climb_progress / 0.6;

        // Smoothstep
        up_progress =
            up_progress
            * up_progress
            * (3 - 2 * up_progress);

        phy_position_x =
            ledge_start_x;

        phy_position_y =
            lerp(
                ledge_start_y,
                ledge_target_y,
                up_progress
            );
    }


    // =================================
    // PHASE 2 - MOVE ONTO PLATFORM
    // =================================

else
{
    if (_mantle_needs_slide)
    {
        // Change the body BEFORE teleporting into the vent.
        player_set_collider(true);

        is_sliding = true;
        is_mantle_lunging = false;
        slide_direction = ledge_direction;
        slide_exit_timer = 0;

        sprite_index = slide_direction > 0
            ? s_Player_Slide_Right
            : s_Player_Slide_Left;

        image_xscale = 1;
        image_index = 0;

        // Direct teleport. No movement through the wall.
        phy_position_x = ledge_target_x;
        phy_position_y = ledge_target_y;

        phy_speed_x = 0;
        phy_speed_y = 0;

        // Run the existing low-exit completion below.
        climb_progress = 1;
    }
    else
    {
        // Normal mantle keeps its animated forward movement.
        var forward_progress = clamp(
            (climb_progress - 0.6) / 0.4,
            0,
            1
        );

        forward_progress =
            forward_progress * forward_progress
            * (3 - 2 * forward_progress);

        phy_position_y = ledge_target_y;

        phy_position_x = lerp(
            ledge_start_x,
            ledge_target_x,
            forward_progress
        );
    }
}


    // =================================
    // FINISHED CLIMB
    // =================================

    if (climb_progress >= 1)
    {
        phy_position_x =
            ledge_target_x;

        phy_position_y =
            ledge_target_y;

        is_ledge_climbing = false;

        wall_jump_lock_time = 0;
        wall_jump_forced_direction = 0;

        wall_jumps_used = 0;


        // =================================
        // MANTLE LUNGE
        // =================================

        // If W + ANY horizontal direction
        // are held when the mantle finishes,
        // launch in THAT direction.
        //
        // It does not matter which side
        // the ledge was on.

// Low exits become a slide, regardless of Ctrl input.
if (_mantle_needs_slide || !player_can_stand())
{
    player_set_collider(true);

    is_sliding = true;
    is_mantle_lunging = false;
    is_slamming = false;

    slide_direction = ledge_direction;
    slide_exit_timer = 0;

    dash_active = false;
    dash_direction = 0;
    dash_current_speed = 0;
    dash_burst_timer = 0;

    phy_speed_x =
        slide_direction * _chip_move_speed * slide_speed_multiplier;

    phy_speed_y = 0;
    on_ground = true;
    coyote_timer = 0;
}
else if (keyboard_check(ord("W"))
&& move != 0)
{
    is_mantle_lunging = true;
            audio_play_sound(sfxJump, 1, false);

            mantle_lunge_direction =
                move;

            // Inject momentum ONCE.
            // Air movement will preserve it.
            phy_speed_x =
                mantle_lunge_direction
                * mantle_lunge_speed
				* speed_boost_multiplier;

            phy_speed_y =
                mantle_lunge_up
				* speed_boost_multiplier;

            // Start wall-jump animation
            sprite_index =
                s_Player_wallJump;

            image_index = 0;
            image_speed = 1;

            image_xscale =
                mantle_lunge_direction;

            // We launched away from the ledge,
            // so do NOT count as grounded.
            on_ground = false;

            coyote_timer = 0;
        }

        else
        {
            phy_speed_x = 0;
            phy_speed_y = 0;

            on_ground = true;
        }


        ledge_direction = 0;
    }
}


// =====================================
// SLIDING INPUT
// =====================================
// =====================================
// SLIDING INPUT / EXIT / COLLIDER
// =====================================

var slide_held = keyboard_check(vk_control);

var _slide_check_direction = is_sliding
    ? slide_direction
    : move;

// Check at the short body's centre height.
// Its horizontal half-width is approximately 30 pixels.
var _slide_wall_blocked = false;

if (_slide_check_direction != 0)
{
    _slide_wall_blocked = collision_line(
        x,
        y - 13,
        x + _slide_check_direction * 31,
        y - 13,
        o_Block,
        false,
        true
    ) != noone;
}

// Start only while grounded and with space ahead.
if (!is_sliding
&& !is_ledge_climbing
&& slide_held
&& on_ground
&& move != 0
&& !_slide_wall_blocked)
{
    is_sliding = true;
    player_set_collider(true);

    dash_active = false;
    dash_direction = 0;
    dash_current_speed = 0;
    dash_burst_timer = 0;

    slide_direction = move;
    slide_exit_timer = 0;
}

// Airborne movement or a wall ends the active slide.
// A low ceiling can still require the short body afterward.
if (is_sliding)
{
var _can_stand_now = player_can_stand();

var _stop_slide =
    _slide_wall_blocked
    || (_can_stand_now && (!on_ground || !slide_held));

if (_stop_slide)
{
    show_debug_message(
        "SLIDE CANCEL"
        + " | airborne=" + string(!on_ground)
        + " | wall=" + string(_slide_wall_blocked)
        + " | ctrl=" + string(slide_held)
        + " | can_stand=" + string(player_can_stand())
        + " | direction=" + string(slide_direction)
    );

    is_sliding = false;
        slide_direction = 0;
        slide_exit_timer = 0;

        if (_slide_wall_blocked)
        {
            phy_speed_x = 0;
        }
    }
}

// Keep the collider and pose consistent even after slide cancellation.
if (is_sliding)
{
    if (!player_collider_short)
    {
        player_set_collider(true);
    }
}
else if (player_collider_short && player_can_stand())
{
    player_set_collider(false);
}
// =====================================
// WALL-JUMP CONTROL LOCK TIMER
// =====================================

if (wall_jump_lock_time > 0)
{
    wall_jump_lock_time -=
        (variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000;

    if (wall_jump_lock_time <= 0)
    {
        wall_jump_lock_time = 0;
        wall_jump_forced_direction = 0;
    }
}

// =====================================
// CURSOR AIMING
// =====================================

var aim_origin_x = x;
var aim_origin_y = y + rig_shoulder_l_y - 64;

aim_angle = point_direction(
    aim_origin_x,
    aim_origin_y,
    mouse_x,
    mouse_y
);

// Small dead zone prevents flickering when
// the cursor is directly above the player.
var aim_dx = mouse_x - aim_origin_x;

if (abs(aim_dx) > 1)
{
    aim_facing = sign(aim_dx);
}

// =====================================
// SPRITE / ANIMATION
// =====================================

// Reset animation direction for non-running states
image_speed = 1;

if (is_ledge_climbing)
{

sprite_index = s_Player_wallHold_Right;

    if (ledge_direction == -1)
    {
        image_xscale = -1;
    }

    else if (ledge_direction == 1)
    {
        image_xscale = 1;
    }
}

else if (player_collider_short)
{
    var _low_facing = is_sliding
        ? slide_direction
        : aim_facing;

    if (_low_facing == 0) _low_facing = 1;

    sprite_index = _low_facing > 0
        ? s_Player_Slide_Right
        : s_Player_Slide_Left;

    image_xscale = 1;
}


// =====================================
// MANTLE LUNGE ANIMATION
// =====================================
// No timer.
// s_Player_wallJump plays once and then
// is_mantle_lunging turns itself off.

else if (is_mantle_lunging)
{
    if (sprite_index != s_Player_wallJump)
    {
        sprite_index =
            s_Player_wallJump;

        image_index = 0;
    }

    image_xscale =
        mantle_lunge_direction;


    // Animation finished
    if (image_index >= image_number - 1)
    {
        is_mantle_lunging = false;
    }
}


// =====================================
// OTHER ANIMATIONS
// =====================================


else if (!on_ground
&& wall_jump_lock_time > 0)
{
sprite_index = s_Player_wallJump;

    image_xscale =
        wall_jump_forced_direction;
}


else if (!on_ground
&& touching_wall
&& coyote_timer <= 0)
{

    if (touching_left_wall)
    {
        sprite_index = s_Player_wallHold_Left;
        image_xscale = -1;
    }
    else if (touching_right_wall)
    {
        sprite_index = s_Player_wallHold_Right;
        image_xscale = 1;
    }
}


else if (!on_ground)
{
sprite_index = s_Player_Air;

    if (move > 0)
    {
        image_xscale = 1;
    }

    else if (move < 0)
    {
        image_xscale = -1;
    }
}


else if (move != 0)
{
    sprite_index = s_Player_Run;
	
	// 1 when moving forward, -1 when backpedaling
    image_speed = move * aim_facing;
	
    if (move > 0)
    {
        image_xscale = 1;
    }

    else if (move < 0)
    {
        image_xscale = -1;
    }

    // Run animation speed follows movement speed
image_speed =
    max(
        0.5,
        abs(phy_speed_x) / _chip_move_speed
    );
}


else
{
    sprite_index = s_Player;
}

// Normal poses face toward the cursor.
// Direction-specific poses keep their forced direction.
/*
var facing_locked =
    is_sliding
    || is_ledge_climbing
    || (!on_ground && wall_jump_lock_time > 0)
    || (!on_ground && touching_wall && coyote_timer <= 0);

if (!facing_locked)
{
    image_xscale = aim_facing;
}
*/
// =====================================
// SLAM INPUT
// =====================================

// Slam only while airborne and not mantling
if (!on_ground
&& !is_slamming
&& !is_ledge_climbing
&& slam_cooldown_timer <= 0)
{
    if (keyboard_check_pressed(ord("S"))
|| keyboard_check_pressed(vk_down))
{
    is_slamming = true;

    // A hit from before the slam must not interrupt the protected descent.
    damage_knockback_timer = 0;
    damage_knockback_pending = false;
    trap_bounce_pending = false;
    trap_knockback_timer = 0;

    slam_distance = 0;
    slam_last_y = phy_position_y;
    slam_power = 1;
}
}



// =====================================
// WALL HOLD STATE
// =====================================

// You are holding the wall unless you
// deliberately press AWAY from it.
var wall_holding =
    (touching_left_wall && move <= 0)
    || (touching_right_wall && move >= 0);


// =====================================
// SLAM AND HORIZONTAL MOVEMENT
// =====================================

if (is_ledge_climbing)
{
    // Ledge system controls movement
    phy_speed_x = 0;
    phy_speed_y = 0;
}

else if (is_slamming)
{
	// =====================================
// SLAM DISTANCE
// =====================================

var slam_delta_y =
    phy_position_y - slam_last_y;

// Only count downward travel.
if (slam_delta_y > 0)
{
    slam_distance += slam_delta_y;
}

slam_last_y =
    phy_position_y;


// =====================================
// SLAM POWER
// =====================================

// Doubles every slam_power_double_distance pixels.
slam_power =
    min(
        slam_power_max,
        power(
            2,
            slam_distance
            / slam_power_double_distance
        )
    );
	
    phy_speed_x = 0;

    phy_speed_y *=
        slam_acceleration;

    if (phy_speed_y < slam_speed)
    {
        phy_speed_y = slam_speed;
    }

    if (phy_speed_y > slam_max_speed)
    {
        phy_speed_y = slam_max_speed;
    }
}


else if (wall_jump_lock_time > 0)
{
    phy_speed_x =
        wall_jump_forced_direction
        * wall_jump_x;
}

// =====================================
// HORIZONTAL MOVEMENT
// =====================================

// Ground dash owns horizontal velocity
// while it is active.
if (is_sliding)
{
    phy_speed_x =
        slide_direction * _chip_move_speed * slide_speed_multiplier;
}
else if (dash_active && on_ground)
{
        phy_speed_x =
            slide_direction
            * _chip_move_speed
            * slide_speed_multiplier
			+ 1;
    }
    // Dash code below handles phy_speed_x.


    // =====================================
    // AIR MOVEMENT / MOMENTUM
    // =====================================

    else if (!on_ground)
    {
        var air_friction = 0.00625;
        var air_accel = 0.35;

        var air_speed_limit =
            _chip_move_speed;


        // Slide double-jump boost has priority
        if (slide_double_boost_stage == 1)
        {
            air_speed_limit =
                _chip_move_speed
                * slide_double_boost_stage1_multiplier;
        }

        else if (slide_double_boost_stage == 2)
        {
            air_speed_limit =
                _chip_move_speed
                * slide_double_boost_stage2_multiplier;
        }

        else if (slide_boost_timer > 0)
        {
            air_speed_limit =
                _chip_move_speed
                * slide_movespeed_multiplier;
        }


        // =================================
        // AIR FRICTION
        // =================================

        if (phy_speed_x > 0)
        {
            phy_speed_x =
                max(
                    0,
                    phy_speed_x - air_friction
                );
        }

        else if (phy_speed_x < 0)
        {
            phy_speed_x =
                min(
                    0,
                    phy_speed_x + air_friction
                );
        }


        // =================================
        // AIR CONTROL
        // =================================

        if (move != 0)
        {
            if (sign(phy_speed_x) == move)
            {
                if (abs(phy_speed_x) < air_speed_limit)
                {
                    phy_speed_x +=
                        move * air_accel;

                    if (abs(phy_speed_x) > air_speed_limit)
                    {
                        phy_speed_x =
                            move
                            * air_speed_limit;
                    }
                }
            }

            else
            {
                phy_speed_x +=
                    move * air_accel;
            }
        }
    }


    // =====================================
    // GROUND SPEED BOOSTS
    // =====================================

    else if (slide_double_boost_stage == 1)
    {
        phy_speed_x =
            move
            * _chip_move_speed
            * slide_double_boost_stage1_multiplier;
    }

    else if (slide_double_boost_stage == 2)
    {
        phy_speed_x =
            move
            * _chip_move_speed
            * slide_double_boost_stage2_multiplier;
    }

    else if (slide_boost_timer > 0)
    {
        phy_speed_x =
            move
            * _chip_move_speed
            * slide_movespeed_multiplier;
    }

    else
    {
        phy_speed_x =
            move * _chip_move_speed;
    }

// =====================================
// DASH COOLDOWNS
// =====================================

// =====================================
// GROUND DASH CHAIN TIMER
// =====================================

if (dash_chain_timer > 0)
{
    dash_chain_timer -=
        (variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000;

    if (dash_chain_timer <= 0)
    {
        dash_chain_timer = 0;
        dash_chain = 0;
    }
}

// Ground dash
if (ground_dash_cooldown_timer > 0)
{
    ground_dash_cooldown_timer -=
        (variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000;

    if (ground_dash_cooldown_timer < 0)
    {
        ground_dash_cooldown_timer = 0;
    }
}


// Air dash
if (air_dash_cooldown_timer > 0)
{
    air_dash_cooldown_timer -=
        (variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000;

    if (air_dash_cooldown_timer < 0)
    {
        air_dash_cooldown_timer = 0;
    }
}


// =====================================
// GROUND DASH
// =====================================

if (dash_active)
{
    if (!on_ground)
    {
        dash_active = false;
        dash_direction = 0;
        dash_current_speed = 0;
        dash_burst_timer = 0;
    }


    // =================================
    // DASH FROM STANDSTILL
    // =================================

    else if (!dash_started_moving)
    {
        dash_burst_timer -=
            (variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000;

        phy_speed_x =
            dash_direction
            * dash_stationary_speed;

        if (dash_burst_timer <= 0)
        {
            dash_active = false;
            dash_direction = 0;
            dash_current_speed = 0;
            dash_burst_timer = 0;

            phy_speed_x = 0;
        }
    }


    // =================================
    // DASH WHILE RUNNING
    // =================================

    else
    {
        // Letting go cancels the boost.
        if (move == 0)
        {
            dash_active = false;
            dash_direction = 0;
            dash_current_speed = 0;

            phy_speed_x = 0;
        }

        // Turning around also cancels it.
        else if (move != dash_direction)
        {
            dash_active = false;
            dash_direction = 0;
            dash_current_speed = 0;

            phy_speed_x =
                move * _chip_move_speed;
        }

        // Still holding the dash direction:
        // decay toward normal running speed.
        else
        {
            dash_current_speed =
                max(
                    _chip_move_speed,
                    dash_current_speed - dash_decay
                );

            phy_speed_x =
                dash_direction
                * dash_current_speed;

            if (dash_current_speed <= _chip_move_speed)
            {
                dash_active = false;
                dash_direction = 0;
                dash_current_speed = 0;
            }
        }
    }
}

// End ground protection when the boost finishes or is cancelled.
if (dash_iframe_is_ground && !dash_active)
{
    dash_iframe_timer = 0;
    dash_iframe_is_ground = false;
}

// =====================================
// DASH INPUT
// =====================================

var dash_pressed =
    keyboard_check_pressed(vk_shift);

if (dash_pressed && !is_sliding)
{
    var dash_dir =
        sign(image_xscale);

    if (dash_dir == 0)
    {
        dash_dir = 1;
    }


    // =================================
    // GROUND DASH
    // =================================

    if (on_ground
    && move != 0
    && ground_dash_cooldown_timer <= 0)
    {	
		audio_play_sound(sfxJumpDash, 1, false);
		dash_iframe_timer = ground_dash_iframe_duration;
        dash_iframe_is_ground = true;
        // Cancel wall-jump control lock
        wall_jump_lock_time = 0;
        wall_jump_forced_direction = 0;

        dash_active = true;
        dash_direction = dash_dir;
        dash_started_moving = true;
		// =================================
		// BUILD DASH CHAIN
		// =================================

		dash_chain =
			min(
				dash_chain + 1,
				dash_chain_max
				);

		dash_chain_timer =
		dash_chain_window;




// First dash gets no extra chain bonus.
// Every dash after it becomes faster.
var chain_bonus =
    (dash_chain - 1)
    * dash_chain_speed_per_dash;


dash_current_speed =
    abs(phy_speed_x)
    + dash_speed
    + chain_bonus;

phy_speed_x =
    dash_direction
    * dash_current_speed;

        ground_dash_cooldown_timer =
            dash_cooldown;
    }


    // =================================
    // AIR DASH
    // =================================

    else if (!on_ground
    && air_dash_cooldown_timer <= 0)
    {
		audio_play_sound(sfxJumpDash, 1, false);
		dash_iframe_timer = air_dash_iframe_duration;
        dash_iframe_is_ground = false;
        // Cancel wall-jump control lock
        wall_jump_lock_time = 0;
        wall_jump_forced_direction = 0;

        phy_speed_x +=
            dash_dir
            * air_dash_speed;

        phy_speed_y = -3;

        dash_active = false;
        dash_direction = 0;

        air_dash_cooldown_timer =
            air_dash_cooldown;
    }
}

// =====================================
// WALL SLIDE FRICTION
// =====================================

var pressing_away_from_wall =
    (touching_left_wall && keyboard_check(ord("D")))
    ||
    (touching_right_wall && keyboard_check(ord("A")));

if (pressing_away_from_wall && wall_slide_active)
{
    phy_speed_y = min(phy_speed_y, 0);

    wall_slide_active = false;
    wall_slide_speed = 0;
}

if (!on_ground
&& wall_holding
&& coyote_timer <= 0
&& !is_slamming
&& !is_sliding
&& !player_collider_short
&& wall_jump_lock_time <= 0)
{
    // Start wall slide when falling
    if (!wall_slide_active
    && phy_speed_y > 0)
    {
        wall_slide_active = true;

        wall_slide_speed =
            phy_speed_y;
    }

    if (wall_slide_active)
    {
        // Neither A nor D is held:
        // slide downward at speed 3
        if (move == 0)
        {
            wall_slide_speed = 3;
        }

        // Holding toward the wall:
        // gradually stop sliding
        else
        {
            wall_slide_speed =
                max(
                    0,
                    wall_slide_speed
                    - wall_slide_decel
                )-0.2865;
        }

        phy_speed_y =
            wall_slide_speed;
    }
}

else
{
    wall_slide_active = false;
    wall_slide_speed = 0;
}


// =====================================
// POST-SLIDE SPEED BOOST TIMER
// =====================================

if (slide_boost_timer > 0)
{
    slide_boost_timer -=
        (variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000;

    if (slide_boost_timer < 0)
    {
        slide_boost_timer = 0;
    }
}



// =====================================
// SLIDE DOUBLE JUMP WINDOW
// =====================================

if (slide_double_jump_timer > 0)
{
    slide_double_jump_timer -=
        (variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000;

    if (slide_double_jump_timer < 0)
    {
        slide_double_jump_timer = 0;
        slide_double_jump_direction = 0;
    }
}

// =====================================
// SLIDE DOUBLE JUMP BOOST
// =====================================

if (slide_double_boost_stage > 0)
{
    slide_double_boost_timer -=
        (variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000;

    if (slide_double_boost_timer <= 0)
    {
        // Stage 1 finished:
        if (slide_double_boost_stage == 1)
        {
            slide_double_boost_stage = 2;

            slide_double_boost_timer =
                slide_double_boost_stage2_duration;
        }

        // Stage 2 finished
        else
        {
            slide_double_boost_stage = 0;
            slide_double_boost_timer = 0;
        }
    }
}

// =====================================
// JUMP AND WALL JUMP
// =====================================

var jump_pressed =
    keyboard_check_pressed(ord("W"))
    || keyboard_check_pressed(vk_up)
    || keyboard_check_pressed(vk_space);


if (jump_pressed
&& !is_ledge_climbing
&& (!is_sliding || player_can_stand()))
{
// =================================
// SLIDE DOUBLE JUMP
// =================================

if (slide_double_jump_timer > 0)
{
    audio_play_sound(sfxJumpDash, 1, false);
    // Use the direction the player is facing NOW,
    // not the direction the original slide started in.
    var double_jump_direction = move;

    // If no A/D is currently held,
    // use the current facing direction.
    if (double_jump_direction == 0)
    {
        double_jump_direction =
            sign(image_xscale);
    }

    // Final fallback to original slide direction
    if (double_jump_direction == 0)
    {
        double_jump_direction =
            slide_double_jump_direction;
    }


    // Smaller upward boost
    phy_speed_y = -3;


    // Give immediate forward momentum
    var slide_double_launch_speed =
        _chip_move_speed
        * slide_double_jump_launch_multiplier
		+2;


    if (abs(phy_speed_x)
    < slide_double_launch_speed)
    {
        phy_speed_x =
            double_jump_direction
            * slide_double_launch_speed;
    }
    else
    {
        // IMPORTANT:
        // If we're already moving faster,
        // still turn that momentum around.
        phy_speed_x =
            double_jump_direction
            * abs(phy_speed_x);
    }


    // Start boost
    slide_double_boost_stage = 1;

    slide_double_boost_timer =
        slide_double_boost_stage1_duration;


    slide_boost_timer = 0;

    slide_double_jump_timer = 0;


    image_xscale =
        double_jump_direction;
}
    


    // =================================
    // NORMAL JUMP / COYOTE JUMP
    // =================================

    else if (on_ground
    || coyote_timer > 0)
    {
        if (is_sliding && player_can_stand())
        {
            audio_play_sound(sfxJump, 1, false);
            // IMPORTANT:
            // Remember which way we were sliding
            // BEFORE resetting slide_direction.
            slide_double_jump_direction =
                slide_direction;

            // Arm second jump press.
            slide_double_jump_timer =
                slide_double_jump_window;


            // Existing strong slide jump.
            phy_speed_y =
                slide_jump_speed;

            slide_boost_timer =
                slide_time;
				if (player_collider_short
	&& player_can_stand())
	{
		player_set_collider(false);
	}
        }

else
{
    audio_play_sound(dash_chain > 0 ? sfxJumpDash : sfxJump, 1, false);
    phy_speed_y =
        jump_speed;

    if (dash_chain > 0)
    {
        var jump_direction = move;

        if (jump_direction == 0)
        {
            jump_direction =
                sign(phy_speed_x);
        }

        if (jump_direction == 0)
        {
            jump_direction =
                sign(image_xscale);
        }


        // Extra forward launch
        phy_speed_x +=
            jump_direction
            * dash_chain
            * dash_chain_jump_bonus;


        // Extra upward launch
        phy_speed_y -=
            dash_chain
            * dash_chain_jump_bonus;


        dash_chain = 0;
        dash_chain_timer = 0;
    }
}


        is_sliding = false;
        slide_direction = 0;

        coyote_timer = 0;
    }


// =================================
// WALL JUMP
// =================================

else if (!on_ground
&& touching_wall)
{
    // LEFT WALL
    if (touching_left_wall
    && left_wall_jumps_used < max_wall_jumps_per_side)
    {
        audio_play_sound(sfxJump, 1, false);
        left_wall_jumps_used += 1;

        phy_speed_y =
            wall_jump_y;

        wall_jump_forced_direction = 1;

        phy_speed_x =
            wall_jump_x;

        wall_jump_lock_time =
            wall_jump_lock_duration;

        image_index = 0;
    }


    // RIGHT WALL
    else if (touching_right_wall
    && right_wall_jumps_used < max_wall_jumps_per_side)
    {
        audio_play_sound(sfxJump, 1, false);
        right_wall_jumps_used += 1;

        phy_speed_y =
            wall_jump_y;

        wall_jump_forced_direction = -1;

        phy_speed_x =
            -wall_jump_x;

        wall_jump_lock_time =
            wall_jump_lock_duration;

        image_index = 0;
    }
	}
}


// =====================================
// SLAM IMPACT
// =====================================
if (on_ground && is_slamming)
{
    var impact_power = clamp(slam_power, 1, slam_power_max);

    var impact_damage = min(
        slam_max_damage,
        slam_base_damage * power(impact_power, slam_damage_power_exponent)
    );

    var impact_radius = min(
        slam_max_radius,
        slam_base_radius * power(impact_power, slam_radius_power_exponent)
    );

    var impact_speed = min(
        slam_max_knockback_speed,
        slam_base_knockback_speed * power(impact_power, slam_knockback_power_exponent)
    );

    // Keep protection through impact and damage checks later this frame.
    slam_iframe_timer = slam_impact_iframe_duration;
    is_slamming = false;
	slam_cooldown_timer = slam_cooldown;
    slam_apply(x, y, impact_radius, impact_damage, impact_speed, id);

    audio_play_sound(sfxSlam, 1, false);

    var slam_fx = instance_create_depth(x, y, depth - 10, oSlamVFX);
    slam_fx.start_slam_vfx(impact_radius, impact_power);

    slam_distance = 0;
    slam_power = 1;
    slam_last_y = phy_position_y;
}

// =====================================
// WEAPON SYSTEM
// =====================================

if (keyboard_check_pressed(ord("1")))
{
    if (weapon_type != "pistol")
    {
        audio_play_sound(sfxSwitchGun, 1, false);
    }
    weapon_type = "pistol";
    sword_swing_timer = 0;
    sword_swing_pending_hit = false;
}

if (keyboard_check_pressed(ord("2")))
{
    if (weapon_type != "sword")
    {
        audio_play_sound(sfxSwordSwitch, 1, false);
    }
    weapon_type = "sword";
}

aim_rig_mode = (weapon_type == "sword")
    ? AimRigMode.TWO_HANDED
    : AimRigMode.ONE_HANDED;

if (weapon_fire_timer > 0)
{
    weapon_fire_timer -= (variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000;

    if (weapon_fire_timer < 0)
    {
        perfe = 0;
    }
}

if (sword_swing_timer > 0)
{
    sword_swing_timer = max(
        0,
        sword_swing_timer - (variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000
    );
}

// =====================================
// PERFECT APEX FLASH TIMER
// =====================================

if (perfect_apex_flash_timer > 0)
{
    perfect_apex_flash_timer -=
        (variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000;

    if (perfect_apex_flash_timer < 0)
    {
        perfect_apex_flash_timer = 0;
    }
}


// =====================================
// PRIMARY FIRE - LEFT MOUSE
// =====================================

// Both buttons reserve the input for syringe use.
var _basher_ui_mouse = variable_global_exists("basher_tuner_capture_mouse") && global.basher_tuner_capture_mouse;
var _syringe_combo =
    !_basher_ui_mouse && mouse_check_button(mb_left)
    && mouse_check_button(mb_right);

if (_syringe_combo
&& (mouse_check_button_pressed(mb_left)
    || mouse_check_button_pressed(mb_right)))
{
    use_syringe(false);
}


if (weapon_type == "pistol")
{
    // Keep the existing hold-to-fire behaviour.
    if (!_basher_ui_mouse && !_syringe_combo
	&& mouse_check_button(mb_left)
	&& weapon_fire_timer <= 0)
    {
        audio_play_sound(sfxGunshot, 1, false);
        weapon_hitscan(
            pistol_damage,
            pistol_range,
            pistol_piercing
        );

        weapon_fire_timer = pistol_cooldown * chip_attack_multiplier();
        gun_reticle_flash_timer = gun_reticle_flash_duration;
    }
}
else if (weapon_type == "sword")
{
    // Start one swing per click; show its trail during the downward strike.
    if (!_basher_ui_mouse && !_syringe_combo
	&& mouse_check_button_pressed(mb_left)
	&& sword_swing_timer <= 0
    && chip_sword_cooldown_timer <= 0)
    {
        sword_swing_timer = max(0.001, sword_config.swing_duration);
        chip_sword_cooldown_timer = sword_swing_timer * chip_attack_multiplier();
        sword_swing_pending_hit = true;
        // Aim independently of the slide's movement/body direction.
        sword_swing_facing = is_sliding
            ? sign(aim_facing)
            : sign(image_xscale);

        if (sword_swing_facing == 0)
        {
            sword_swing_facing = 1;
        }
    }

    if (sword_swing_pending_hit
        && 1 - sword_swing_timer / max(0.001, sword_config.swing_duration)
            >= clamp(sword_config.windup_phase, 0.001, 0.998))
    {
        sword_swing_pending_hit = false;
        var _slash_sound = sword_slash_sound_index == 0
            ? sfxSwordSlash1 : sfxSwordSlash2;
        audio_play_sound(_slash_sound, 1, false);
        sword_slash_sound_index = 1 - sword_slash_sound_index;

        var slash = instance_create_depth(
            x + sword_config.slash_forward * sword_swing_facing,
            y + sword_config.slash_down,
            depth - 1,
            oSlashEffect
        );

        slash.image_xscale = sword_swing_facing * sword_config.slash_scale;
        slash.image_yscale = sword_config.slash_scale;
        slash.slash_owner = id;
        slash.sync_sword_swing();
        slash.slash_damage = sword_config.slash_damage;
        slash.knockback_force = sword_config.slash_knockback;
    }
}


// =====================================
// ALT FIRE - RIGHT MOUSE / THROW COIN
// =====================================
timerf3 = timerf3 - (variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000
if (keyboard_check_direct(vk_f3))
{ 
    // Only throw if we actually have a coin.
    if (coin_count > 0)
    {
		if (timerf3 <=0) {
        var _debug_coin_muzzle = player_get_muzzle();
        var coin = instance_create_layer(
            _debug_coin_muzzle.muzzle_x,
            _debug_coin_muzzle.muzzle_y,
            "Instances",
            o_Coin
        );
		
		coin.split_threshold =
			coin_split_y_speed_threshold;
			
// =================================
// COIN AGE / OWNER
// =================================

coin_throw_serial += 1;
coin_count += 99;

coin.coin_owner = id;
coin.throw_id = coin_throw_serial;

coin.is_pinned = false;
coin.pin_owner = noone;
			
			


        // =================================
        // AIM AT MOUSE
        // =================================

        var coin_throw_direction =
            point_direction(
                coin.x,
                coin.y,
                mouse_x,
                mouse_y
            );


        // =================================
        // INHERIT PLAYER MOMENTUM
        // =================================

        coin.phy_speed_x =
            phy_speed_x;

        coin.phy_speed_y =
            phy_speed_y;


        // =================================
        // ADD THROW FORCE
        // =================================

        coin.phy_speed_x +=
            lengthdir_x(
                3,
                coin_throw_direction
            );

        coin.phy_speed_y = -5;


        // =================================
        // CONSUME COIN
        // =================================

        coin_count -= 1;}
    }
}

if (!_basher_ui_mouse && !_syringe_combo
&& mouse_check_button_pressed(mb_right))
{
    // Only throw if we actually have a coin.
    if (coin_count > 0)
    {
		
        var _coin_muzzle = player_get_muzzle();
        var coin = instance_create_layer(
            _coin_muzzle.muzzle_x,
            _coin_muzzle.muzzle_y,
            "Instances",
            o_Coin
        );
		
		coin.split_threshold =
			coin_split_y_speed_threshold;
			
// =================================
// COIN AGE / OWNER
// =================================

coin_throw_serial += 1;

coin.coin_owner = id;
coin.throw_id = coin_throw_serial;

coin.is_pinned = false;
coin.pin_owner = noone;
			
			


        // =================================
        // AIM AT MOUSE
        // =================================

        var coin_throw_direction =
            point_direction(
                coin.x,
                coin.y,
                mouse_x,
                mouse_y
            );


        // =================================
        // INHERIT PLAYER MOMENTUM
        // =================================

        coin.phy_speed_x =
            phy_speed_x;

        coin.phy_speed_y =
            phy_speed_y;


        // =================================
        // ADD THROW FORCE
        // =================================

        coin.phy_speed_x +=
            lengthdir_x(
                3,
                coin_throw_direction
            );

        coin.phy_speed_y = -5;


        // =================================
        // CONSUME COIN
        // =================================

        coin_count -= 1;
    }
}

// =====================================
// COIN ANCHOR COOLDOWN
// =====================================

if (coin_anchor_cooldown_timer > 0)
{
    coin_anchor_cooldown_timer -=
        (variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000;

    if (coin_anchor_cooldown_timer < 0)
    {
        coin_anchor_cooldown_timer = 0;
    }
}




// =====================================
// DAMAGE COOLDOWN
// =====================================

dmg_cooldown -=
    (variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000;

if (dmg_cooldown < 0)
{
    dmg_cooldown = 0;
}


// =====================================
// COIN THROW COOLDOWN
// =====================================

// =====================================
// COIN RECHARGE
// =====================================

if (coin_count < coin_max)
{
    coin_recharge_timer +=
        (variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000;


    // Gain one coin every recharge interval.
    while (
        coin_recharge_timer >= coin_recharge_time
        && coin_count < coin_max
    )
    {
        coin_count += 1;

        coin_recharge_timer -=
            coin_recharge_time;
    }
}
else
{
    // Fully stocked.
    coin_count = coin_max;
    coin_recharge_timer = 0;
}

// =====================================
// CLEAN PINNED COIN REFERENCE
// =====================================

if (
    pinned_coin != noone
    && !instance_exists(pinned_coin)
)
{
    pinned_coin = noone;
}

// =====================================
// COIN ANCHOR ACTIVE ITEM
// MIDDLE MOUSE
// =====================================

if (
    item_coin_anchor
    && !_basher_ui_mouse
    && mouse_check_button_pressed(mb_middle)
    && coin_anchor_cooldown_timer <= 0
    && pinned_coin == noone
)
{
    var _oldest_coin = noone;
    var _oldest_id = infinity;

    var _coin_count =
        instance_number(o_Coin);


    // =================================
    // FIND OLDEST PLAYER-THROWN COIN
    // =================================

    for (
        var i = 0;
        i < _coin_count;
        i++
    )
    {
        var _candidate =
            instance_find(
                o_Coin,
                i
            );

        if (!instance_exists(_candidate))
        {
            continue;
        }


        // Ignore debug coins / coins without ownership data.
        if (
            !variable_instance_exists(
                _candidate,
                "coin_owner"
            )
        )
        {
            continue;
        }


        if (_candidate.coin_owner != id)
        {
            continue;
        }


        if (_candidate.is_pinned)
        {
            continue;
        }


        // Lowest throw_id = oldest coin.
        if (_candidate.throw_id < _oldest_id)
        {
            _oldest_id =
                _candidate.throw_id;

            _oldest_coin =
                _candidate;
        }
    }


    // =================================
    // PIN COIN
    // =================================

    if (_oldest_coin != noone)
    {
        pinned_coin =
            _oldest_coin;

        pinned_coin.is_pinned = true;
        pinned_coin.pin_owner = id;


        // Start 8-second cooldown.
        coin_anchor_cooldown_timer =
            coin_anchor_cooldown;
    }
}


if (pHP <= 0)
{
    instance_destroy();
    exit;
}
// =====================================
//TRAP KNOCKBACK 
// =====================================

if (variable_instance_exists(id, "trap_bounce_pending"))
{
    if (trap_bounce_pending)
    {
        is_slamming = false;
        phy_speed_y = -trap_bounce_speed;
        trap_bounce_pending = false;
    }
}

if (variable_instance_exists(id, "trap_knockback_timer"))
{
    if (trap_knockback_timer > 0)
    {
        phy_speed_x = trap_knockback_speed_x;
        trap_knockback_timer = max(
            0,
            trap_knockback_timer - (variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000
        );
    }
}

// Apply after movement so held movement keys cannot erase the recoil.
if (damage_knockback_pending)
{
    is_slamming = false;
    phy_speed_y = min(phy_speed_y, -damage_knockback_lift);
    damage_knockback_pending = false;
}
if (damage_knockback_timer > 0)
{
    phy_speed_x = damage_knockback_speed_x;
    damage_knockback_timer = max(
        0, damage_knockback_timer - (variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000
    );
}


// Expose the actual wall-hold state to chip enemies (wall_holding is local).
chip_wall_holding_now = !on_ground && wall_holding
    && !is_slamming && !is_ledge_climbing
    && wall_jump_lock_time <= 0
    && chip_wall_release_timer <= 0 && !chip_waiting_for_landing
    && abs(phy_speed_y) < 1 && abs(phy_speed_x) < 1;

// =====================================
// WALL SLIDE AUDIO
// =====================================
// Loop only while descending along a wall; stop on jumps, holds and landings.
var _wall_slide_sounding = wall_slide_active && wall_holding && touching_wall
    && !on_ground && phy_speed_y > 0.1 && wall_jump_lock_time <= 0
    && !is_slamming && !is_ledge_climbing && !is_mantle_lunging
    && coyote_timer <= 0 && damage_knockback_timer <= 0;

if (_wall_slide_sounding)
{
    if (wall_slide_sound == -1 || !audio_is_playing(wall_slide_sound))
    {
        wall_slide_sound = audio_play_sound(sfxWallSlide, 1, true);
    }
}
else
{
    stop_wall_slide_sfx();
}

// =====================================
// GROUND SLIDE AUDIO
// =====================================
// Keep the ground-slide loop tied to movement, just like the wall-slide loop.
var _slide_sounding = is_sliding && on_ground && _footstep_moved
    && abs(phy_speed_x) > 0.1 && phy_speed_y >= 0
    && !is_slamming && !is_ledge_climbing && !is_mantle_lunging
    && damage_knockback_timer <= 0;

if (_slide_sounding)
{
    if (slide_sound == -1 || !audio_is_playing(slide_sound))
    {
        slide_sound = audio_play_sound(sfxSlide, 1, true);
    }
}
else
{
    stop_slide_sfx();
}

// =====================================
// RUNNING FOOTSTEPS
// =====================================
// Check after jumps, slides, dashes and recoil have resolved for this frame.
var _footstep_running = on_ground && move != 0 && _footstep_moved
    && abs(phy_speed_x) > 0.1 && phy_speed_y >= 0
    && !is_sliding && !is_slamming
    && !is_ledge_climbing && !is_mantle_lunging
    && damage_knockback_timer <= 0
    && (!variable_instance_exists(id, "trap_knockback_timer") || trap_knockback_timer <= 0);

if (_footstep_running)
{
    var _footstep_dt = (variable_global_exists("dev_delta_time")
        ? global.dev_delta_time : delta_time) / 1000000;
    // Advance the cadence with current speed, including the ground dash burst.
    var _footstep_speed_ratio = abs(phy_speed_x) / max(0.001, move_speed);
    footstep_timer = max(0, footstep_timer - _footstep_dt * max(0.5, _footstep_speed_ratio));

    if (footstep_timer <= 0)
    {
        audio_play_sound(sfxFootsteps, 1, false);
        footstep_timer = footstep_interval;
    }
}
else
{
    // Start with a footstep when grounded running resumes.
    footstep_timer = 0;
}
