// =====================================
// KEEP PLAYER UPRIGHT
// =====================================

phy_angular_velocity = 0;
phy_rotation = 0;
phy_fixed_rotation = true;

// =====================================
// ACTIVE SPEED BOOST
// =====================================

var speed_boost_multiplier = 1;

// Normal post-slide boost
if (slide_boost_timer > 0)
{
    speed_boost_multiplier = 1.15;
}

// Slide double jump - stage 1
if (slide_double_boost_stage == 1)
{
    speed_boost_multiplier = 1.3;
}

// Slide double jump - stage 2
if (slide_double_boost_stage == 2)
{
    speed_boost_multiplier = 1.25;
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
        y - 64,
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
        y - 64,
        o_Block,
        false,
        true
    );


// =====================================
// NORMAL WALL DETECTION
// =====================================

var touching_left_wall =
    left_wall_lower != noone
    && left_wall_upper != noone;

var touching_right_wall =
    right_wall_lower != noone
    && right_wall_upper != noone;

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
    coyote_timer -= delta_time / 1000000;

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
    wall_jumps_used = 0;
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
&& wall_jump_lock_time <= 0
&& coyote_timer <= 0)
{
    // ---------------------------------
    // LEFT LEDGE
    // ---------------------------------

    // Must hold W AND move toward the wall.
    if (left_ledge
   // && mantle_held
    && move < 0)
    {
        is_ledge_climbing = true;

        ledge_direction = -1;
        ledge_climb_timer = 0;

        ledge_start_x = phy_position_x;
        ledge_start_y = phy_position_y;

        // Move left onto platform
        ledge_target_x =
            phy_position_x
            - ledge_climb_forward;

        // Keeping your current mantle target
        // behaviour for now.
        ledge_target_y =
            left_wall_lower.bbox_top
            - ground_check_y_offset;

        phy_speed_x = 0;
        phy_speed_y = 0;

        is_slamming = false;
        is_sliding = false;

        slide_direction = 0;
        slide_exit_timer = 0;

        image_index = 0;
    }


    // ---------------------------------
    // RIGHT LEDGE
    // ---------------------------------

    else if (right_ledge
   // && mantle_held
    && move > 0)
    {
        is_ledge_climbing = true;

        ledge_direction = 1;
        ledge_climb_timer = 0;

        ledge_start_x = phy_position_x;
        ledge_start_y = phy_position_y;

        // Move right onto platform
        ledge_target_x =
            phy_position_x
            + ledge_climb_forward;

        // Keeping your current mantle target
        // behaviour for now.
        ledge_target_y =
            right_wall_lower.bbox_top
            - ground_check_y_offset;

        phy_speed_x = 0;
        phy_speed_y = 0;

        is_slamming = false;
        is_sliding = false;

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
    // Prevent normal movement from pulling us down
    phy_speed_x = 0;
    phy_speed_y = 0;

    ledge_climb_timer +=
        delta_time / 1000000;


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
        var forward_progress =
            (climb_progress - 0.6)
            / 0.4;

        forward_progress =
            clamp(
                forward_progress,
                0,
                1
            );

        // Smoothstep
        forward_progress =
            forward_progress
            * forward_progress
            * (3 - 2 * forward_progress);

        phy_position_y =
            ledge_target_y;

        phy_position_x =
            lerp(
                ledge_start_x,
                ledge_target_x,
                forward_progress
            );
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

        if (keyboard_check(ord("W"))
        && move != 0)
        {
            is_mantle_lunging = true;

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

var slide_held =
    keyboard_check(vk_control);


// Don't start sliding during a mantle
if (!is_sliding
&& !is_ledge_climbing
&& slide_held
&& on_ground
&& move != 0)
{
    is_sliding = true;

    slide_direction = move;

    slide_exit_timer = 0;
}


// =====================================
// SLIDE EXIT
// =====================================

if (is_sliding)
{
    if (!slide_held)
    {
        is_sliding = false;
        slide_direction = 0;
        slide_exit_timer = 0;
    }

    else if (!on_ground)
    {
        slide_exit_timer +=
            delta_time / 1000000;

        if (slide_exit_timer >= 0)
        {
            is_sliding = false;
            slide_direction = 0;
            slide_exit_timer = 0;
        }
    }

    else
    {
        slide_exit_timer = 0;
    }
}


// =====================================
// WALL-JUMP CONTROL LOCK TIMER
// =====================================

if (wall_jump_lock_time > 0)
{
    wall_jump_lock_time -=
        delta_time / 1000000;

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

else if (is_sliding)
{
    if (slide_direction == 1)
    {
        sprite_index = s_Player_Slide_Right;
        image_xscale = 1;
    }

    else if (slide_direction == -1)
    {
        sprite_index = s_Player_Slide_Left;
        image_xscale = 1;
    }
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
        abs(phy_speed_x) / move_speed
    );
}


else
{
    sprite_index = s_Player;
}

// Normal poses face toward the cursor.
// Direction-specific poses keep their forced direction.

var facing_locked =
    is_sliding
    || is_ledge_climbing
    || (!on_ground && wall_jump_lock_time > 0)
    || (!on_ground && touching_wall && coyote_timer <= 0);

if (!facing_locked)
{
    image_xscale = aim_facing;
}

// =====================================
// SLAM INPUT
// =====================================

// Slam only while airborne and not mantling
if (!on_ground
&& !is_slamming
&& !is_ledge_climbing)
{
    if (keyboard_check_pressed(ord("S"))
    || keyboard_check_pressed(vk_down))
    {
        is_slamming = true;
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
if (dash_active && on_ground)
{
    // Dash code below handles phy_speed_x.
}

else if (is_sliding)
{
        phy_speed_x =
            slide_direction
            * move_speed
            * slide_speed_multiplier;
    }


    // =====================================
    // AIR MOVEMENT / MOMENTUM
    // =====================================

    else if (!on_ground)
    {
        var air_friction = 0.025;
        var air_accel = 0.35;

        var air_speed_limit =
            move_speed;


        // Slide double-jump boost has priority
        if (slide_double_boost_stage == 1)
        {
            air_speed_limit =
                move_speed
                * slide_double_boost_stage1_multiplier;
        }

        else if (slide_double_boost_stage == 2)
        {
            air_speed_limit =
                move_speed
                * slide_double_boost_stage2_multiplier;
        }

        else if (slide_boost_timer > 0)
        {
            air_speed_limit =
                move_speed
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
            * move_speed
            * slide_double_boost_stage1_multiplier;
    }

    else if (slide_double_boost_stage == 2)
    {
        phy_speed_x =
            move
            * move_speed
            * slide_double_boost_stage2_multiplier;
    }

    else if (slide_boost_timer > 0)
    {
        phy_speed_x =
            move
            * move_speed
            * slide_movespeed_multiplier;
    }

    else
    {
        phy_speed_x =
            move * move_speed;
    }

// =====================================
// DASH COOLDOWNS
// =====================================

// Ground dash
if (ground_dash_cooldown_timer > 0)
{
    ground_dash_cooldown_timer -=
        delta_time / 1000000;

    if (ground_dash_cooldown_timer < 0)
    {
        ground_dash_cooldown_timer = 0;
    }
}


// Air dash
if (air_dash_cooldown_timer > 0)
{
    air_dash_cooldown_timer -=
        delta_time / 1000000;

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
            delta_time / 1000000;

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
                move * move_speed;
        }

        // Still holding the dash direction:
        // decay toward normal running speed.
        else
        {
            dash_current_speed =
                max(
                    move_speed,
                    dash_current_speed - dash_decay
                );

            phy_speed_x =
                dash_direction
                * dash_current_speed;

            if (dash_current_speed <= move_speed)
            {
                dash_active = false;
                dash_direction = 0;
                dash_current_speed = 0;
            }
        }
    }
}

// =====================================
// DASH INPUT
// =====================================

var dash_pressed =
    keyboard_check_pressed(vk_shift);

if (dash_pressed)
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
        // Cancel wall-jump control lock
        wall_jump_lock_time = 0;
        wall_jump_forced_direction = 0;

        dash_active = true;
        dash_direction = dash_dir;
        dash_started_moving = true;

        dash_current_speed =
            abs(phy_speed_x)
            + dash_speed;

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
                );
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
        delta_time / 1000000;

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
        delta_time / 1000000;

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
        delta_time / 1000000;

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
&& !is_ledge_climbing)
{
// =================================
// SLIDE DOUBLE JUMP
// =================================

if (slide_double_jump_timer > 0)
{
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
        move_speed
        * slide_double_jump_launch_multiplier;


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
        if (is_sliding)
        {
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
        }

        else
        {
            phy_speed_y =
                jump_speed;
        }


        is_sliding = false;
        slide_direction = 0;

        coyote_timer = 0;
    }


    // =================================
    // WALL JUMP
    // =================================

    else if (!on_ground
    && touching_wall
    && wall_jumps_used < max_wall_jumps)
    {
        wall_jumps_used += 1;

        phy_speed_y =
            wall_jump_y;


        if (touching_left_wall)
        {
            wall_jump_forced_direction = 1;

            phy_speed_x =
                wall_jump_x;
        }

        else if (touching_right_wall)
        {
            wall_jump_forced_direction = -1;

            phy_speed_x =
                -wall_jump_x;
        }


        wall_jump_lock_time =
            wall_jump_lock_duration;

        image_index = 0;
    }
}


// =====================================
// END SLAM WHEN LANDING
// =====================================

if (on_ground)
{
    is_slamming = false;
}

// =====================================
// MELEE ATTACK - RIGHT MOUSE
// =====================================

if (keyboard_check_pressed(ord("Q")))
{
    var slash_dir = sign(image_xscale);

    if (slash_dir == 0)
    {
        slash_dir = 1;
    }

    var slash = instance_create_depth(
        x + (40 * slash_dir),
        y,
        depth - 1,
        oSlashEffect
    );

    slash.image_xscale = slash_dir;
}
// =====================================
// WEAPON SYSTEM
// =====================================

if (weapon_fire_timer > 0)
{
    weapon_fire_timer -=
        delta_time / 1000000;

    if (weapon_fire_timer < 0)
    {
        weapon_fire_timer = 0;
    }
}


// =====================================
// PRIMARY FIRE - LEFT MOUSE
// =====================================

if (mouse_check_button(mb_left))
{
    if (weapon_fire_timer <= 0)
    {
        if (weapon_type == "pistol")
        {
            weapon_hitscan(
                pistol_damage,
                pistol_range,
                pistol_piercing
            );

            weapon_fire_timer =
                pistol_cooldown;
        }
    }
}


/* (TOO EARLY TO BEGIN WITH)
// =====================================
// ALT FIRE - RIGHT MOUSE / THROW COIN
// =====================================

if (mouse_check_button_pressed(mb_right))
{
    if (coin_throw_timer <= 0)
    {
        var coin = instance_create_layer(
            x + 32,
            y - 64,
            "Instances",
            o_Coin
        );


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

        coin.phy_speed_x = phy_speed_x;
        coin.phy_speed_y = phy_speed_y;


        // =================================
        // ADD THROW FORCE
        // =================================

        coin.phy_speed_x +=
            lengthdir_x(
                3,
                coin_throw_direction
            );

        coin.phy_speed_y = -5;

        //coin.phy_speed_y +=
        //    lengthdir_y(
        //        5,
        //        coin_throw_direction
        //    );


        // Cooldown
        coin_throw_timer = coin_cooldown;
    }
}

*/


if (place_meeting(x, y, oEnemyParent)
&& dmg_cooldown = 0)


// =====================================
// DAMAGE COOLDOWN
// =====================================

dmg_cooldown -=
    delta_time / 1000000;

if (dmg_cooldown < 0)
{
    dmg_cooldown = 0;
}


// =====================================
// COIN THROW COOLDOWN
// =====================================

if (coin_throw_timer > 0)
{
    coin_throw_timer -=
        delta_time / 100000;

    if (coin_throw_timer < 0)
    {
        coin_throw_timer = 0;
    }
}


// =====================================
// ENEMY CONTACT DAMAGE
// =====================================

if (place_meeting(
        x,
        y,
        oEnemy_TEMP
    )
&& dmg_cooldown = 0)

	dmg_cooldown -= delta_time / 1000000;
	if (dmg_cooldown < 0){
		dmg_cooldown = 0;
	}

	
if (place_meeting(x, y, oEnemyParent)  && dmg_cooldown =0) //if the enemy and player are in the same position
//and if damage cooldown is precisely zero, which is what we begin with // I AM ASSUMING THAT THIS CODE PART IS NOW OBSOLETE BUT I KEPT IT REGARDLESS IN CASE SOMETHING GOES WRONG
{
	pHP -=10;
	show_debug_message(pHP);
	dmg_cooldown = 1; //dmg cooldown is set to three
	//because our dps is exactly one, whatever we set here will be in seconds
	show_debug_message("PLAYER COLLIDED WITH ENEMY! and it is on CD");
}

if(pHP <= 0)
{instance_destroy();
}