// =====================================
// KEEP PLAYER UPRIGHT
// =====================================

// Keep the physics body from rotating
phy_angular_velocity = 0;
phy_rotation = 0;


// =====================================
// GROUND AND WALL DETECTION
// =====================================

var on_ground = place_meeting(x + 4, y + 16, o_Block) || place_meeting(x - 4, y + 16, o_Block);

var touching_left_wall = place_meeting(x - 20, y, o_Block);
var touching_right_wall = place_meeting(x + 20, y, o_Block);

var touching_wall = touching_left_wall || touching_right_wall;


// =====================================
// COYOTE TIME
// =====================================

if (on_ground)
{
    // Refresh the timer while standing on the ground
    coyote_timer = coyote_duration;
}
else
{
    // Count down while in the air
    coyote_timer -= delta_time / 1000000;

    // Prevent the timer from becoming negative
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

if (keyboard_check(vk_right) || keyboard_check(ord("D")))
{
    move += 1;
}

if (keyboard_check(vk_left) || keyboard_check(ord("A")))
{
    move -= 1;
}


// =====================================
// SLIDING INPUT
// =====================================

var slide_held =
    keyboard_check(vk_control);

// Start sliding only if not already sliding
if (!is_sliding && slide_held && on_ground && move != 0)
{
    is_sliding = true;

    // Lock the direction when the slide begins
    slide_direction = move;

    // Reset the exit timer
    slide_exit_timer = 0;
}

// =====================================
// SLIDE EXIT DELAY none
// =====================================

if (is_sliding)
{
    // Releasing the slide key ends sliding immediately
    if (!slide_held)
    {
        is_sliding = false;
        slide_direction = 0;
        slide_exit_timer = 0;
    }
    // If the player leaves the ground, start counting
    else if (!on_ground)
    {
        slide_exit_timer += delta_time / 1000000;

        // End sliding after 0.3 seconds off the ground
        if (slide_exit_timer >= 0)
        {
            is_sliding = false;
            slide_direction = 0;
            slide_exit_timer = 0;
        }
    }
    // If the player is grounded again, reset the timer
    else
    {
        slide_exit_timer = 0;
    }
}


// =====================================
// SPRITE / ANIMATION
// =====================================

if (is_sliding)
{
    // Sliding sprites
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
else if (!on_ground)
{
    // Air animation
    sprite_index = AIR_TEMP;

    // Keep facing the direction of movement
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
    // Walking animation
    sprite_index = s_Player_Run;

    // Face the direction we're moving
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
    // Idle
    sprite_index = s_Player;
}


// =====================================
// WALL-JUMP CONTROL LOCK
// =====================================

// Count down the lock timer
if (wall_jump_lock_time > 0)
{
    wall_jump_lock_time -= delta_time / 1000000;

    if (wall_jump_lock_time < 0)
    {
        wall_jump_lock_time = 0;
    }
}


// =====================================
// SLAM INPUT
// =====================================

// Slam only while airborne
if (!on_ground && !is_slamming)
{
    if (keyboard_check_pressed(ord("S"))
    || keyboard_check_pressed(vk_down))
    {
        is_slamming = true;
    }
}


// =====================================
// SLAM AND HORIZONTAL MOVEMENT
// =====================================

if (is_slamming)
{
    // Force the player straight downward
    phy_speed_x = 0;

    // Accelerate the slam
    phy_speed_y *= slam_acceleration;

    // Ensure the slam starts with a meaningful downward speed
    if (phy_speed_y < slam_speed)
    {
        phy_speed_y = slam_speed;
    }

    // Prevent unlimited speed
    if (phy_speed_y > slam_max_speed)
    {
        phy_speed_y = slam_max_speed;
    }
}
else if (wall_jump_lock_time > 0)
{
    // During the wall-jump lock, ignore normal movement
    phy_speed_x = wall_jump_forced_direction * wall_jump_x;
}
else
{
    // =====================================
    // HORIZONTAL MOVEMENT
    // =====================================

if (is_sliding)
{
    // Sliding movement: 1.5 times normal speed
    phy_speed_x =
        slide_direction * move_speed * slide_speed_multiplier;
}
else if (slide_boost_timer > 0)
{
    // 30% faster for 4 seconds after a slide jump
    phy_speed_x =
        move * move_speed * slide_movespeed_multiplier;
}
else
{
    // Normal movement
    phy_speed_x = move * move_speed;
}
}

// =====================================
// POST-SLIDE SPEED BOOST TIMER
// =====================================

if (slide_boost_timer > 0)
{
    slide_boost_timer -= delta_time / 1000000;

    if (slide_boost_timer < 0)
    {
        slide_boost_timer = 0;
    }
}


// =====================================
// JUMP AND WALL JUMP
// =====================================

if (keyboard_check_pressed(ord("W"))
|| keyboard_check_pressed(vk_up)
|| keyboard_check_pressed(vk_space))
{
    // Normal jump or coyote-time jump
    if (on_ground || coyote_timer > 0)
    {
        // Stronger jump while sliding
        if (is_sliding)
{
    // Stronger jump while sliding
    phy_speed_y = slide_jump_speed;

    // Start the 4-second speed boost
    slide_boost_timer = slide_time;
}
else
{
    // Normal jump
    phy_speed_y = jump_speed;
}

        // Stop sliding after jumping
        is_sliding = false;
        slide_direction = 0;

        // Consume coyote time
        coyote_timer = 0;
    }
    // Wall jump
	else if (!on_ground && touching_wall && wall_jumps_used < max_wall_jumps)
    {
        // Use one wall jump
        wall_jumps_used += 1;

        // Upward movement
        phy_speed_y = wall_jump_y;

        // Force movement away from the wall
        if (touching_left_wall)
        {
            wall_jump_forced_direction = 1;
            phy_speed_x = wall_jump_x;
        }
        else if (touching_right_wall)
        {
            wall_jump_forced_direction = -1;
            phy_speed_x = -wall_jump_x;
        }

        // Disable directional control temporarily
        wall_jump_lock_time = wall_jump_lock_duration;
    }
}


// =====================================
// END SLAM WHEN LANDING
// =====================================

if (on_ground)
{
    is_slamming = false;
}


//show_debug_message(
//    "Left: " + string(touching_left_wall)
//    + " | Right: " + string(touching_right_wall)
//    + " | Wall jumps used: " + string(wall_jumps_used)
//);


// =====================================
// WEAPON SYSTEM
// =====================================

// Count down cooldown
if (weapon_fire_timer > 0)
{
    weapon_fire_timer -= delta_time / 1000000;

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

            weapon_fire_timer = pistol_cooldown;
        }
    }
}


// =====================================
// ALT FIRE - RIGHT MOUSE
// =====================================

 //Reserved for future alt-fire abilities

if (mouse_check_button_pressed(mb_right))
{
    // Add alt-fire code here later
}
//dmg cooldown is set to zero by default

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

	
if (place_meeting(x, y, oEnemy_TEMP)  && dmg_cooldown =0) //if the enemy and player are in the same position
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