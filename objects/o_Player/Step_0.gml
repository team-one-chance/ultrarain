// =====================================
// KEEP PLAYER UPRIGHT
// =====================================

phy_angular_velocity = 0;
phy_rotation = 0;


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

// BOTH points must detect ground
var on_ground = ground_left || ground_right;


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
	
	// middle...
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
// middle...
	var right_wall_mid =
    collision_point(
        x + 15,
        y - 24,
        o_Block,
        false,
        true
    );
// right wall up
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

// Lower part touches wall,
// upper part is above the wall.

var left_ledge =
    left_wall_lower != noone
    && left_wall_mid != noone
    && left_wall_upper == noone;

var right_ledge =
    right_wall_lower != noone
    && right_wall_mid != noone
    && right_wall_upper == noone;


// =====================================
// COYOTE TIME
// =====================================

if (on_ground)
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

    if (left_ledge)
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

        // Put feet at top of block
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

    else if (right_ledge)
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

        // Put feet at top of block
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

        phy_speed_x = 0;
        phy_speed_y = 0;

        is_ledge_climbing = false;
        ledge_direction = 0;

        wall_jump_lock_time = 0;
        wall_jump_forced_direction = 0;

        wall_jumps_used = 0;

        // We deliberately placed the player
        // onto the top of the platform.
        // Prevent an AIR_TEMP frame here.
        on_ground = true;
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
// SPRITE / ANIMATION
// =====================================

if (is_ledge_climbing)
{
    // Replace this later with a dedicated
    // climbing animation if you make one.
    sprite_index = WALLHOLD_TEMP;

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
        sprite_index = SLIDE_TEMP;
        image_xscale = 1;
    }

    else if (slide_direction == -1)
    {
        sprite_index = SLIDE_TEMP_1;
        image_xscale = 1;
    }
}

else if (!on_ground
&& wall_jump_lock_time > 0)
{
    sprite_index = WALLJUMP_TEMP;

    image_xscale =
        wall_jump_forced_direction;
}

else if (!on_ground
&& touching_wall
&& coyote_timer <= 0)
{
    sprite_index = WALLHOLD_TEMP;

    if (touching_left_wall)
    {
        image_xscale = -1;
    }

    else if (touching_right_wall)
    {
        image_xscale = 1;
    }
}

else if (!on_ground)
{
    sprite_index = AIR_TEMP;

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

    if (move > 0)
    {
        image_xscale = 1;
    }

    else if (move < 0)
    {
        image_xscale = -1;
    }
}

else
{
    sprite_index = s_Player;
}


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

else
{
    // =====================================
    // HORIZONTAL MOVEMENT
    // =====================================

    if (is_sliding)
    {
        phy_speed_x =
            slide_direction
            * move_speed
            * slide_speed_multiplier;
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
// JUMP AND WALL JUMP
// =====================================

var jump_pressed =
    keyboard_check_pressed(ord("W"))
    || keyboard_check_pressed(vk_up)
    || keyboard_check_pressed(vk_space);


// Ignore jump input while automatic mantle
// is happening.
if (jump_pressed
&& !is_ledge_climbing)
{
    // =================================
    // NORMAL JUMP / COYOTE JUMP
    // =================================

    if (on_ground
    || coyote_timer > 0)
    {
        if (is_sliding)
        {
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


// =====================================
// ALT FIRE - RIGHT MOUSE
// =====================================

if (mouse_check_button_pressed(mb_right))
{
    // Reserved for future alt-fire abilities
}

	dmg_cooldown -= delta_time / 1000000;
	if (dmg_cooldown < 0){
		dmg_cooldown = 0;
	}
	
 //every second, damage cooldown is reduced by one
//now the issue with this is, it runs with the game, not with how long the player and enemy are in contact
//to fix this, we're gonna need an if condition that obliges to the following rules
//if enemy and player collide, -10 hp, THEN wait for as long as damage_cooldown says so
//that means, you take damage if cooldown is at zero
//in the beginning, cooldown will be zero cause you haven't taken any damage yet
//but everytime you do take damage, a cooldown will start.
//until that cooldown is set to zero, you won't take any further damage

	
if (place_meeting(x, y, oEnemyParent)  && dmg_cooldown =0) //if the enemy and player are in the same position
//and if damage cooldown is precisely zero, which is what we begin with
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