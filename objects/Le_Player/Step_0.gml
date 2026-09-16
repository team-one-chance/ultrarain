// =====================================
// KEEP PLAYER UPRIGHT
// =====================================

// Keep the physics body from rotating
phy_angular_velocity = 0;
phy_rotation = 0;


// =====================================
// GROUND AND WALL DETECTION
// =====================================

var on_ground = place_meeting(x, y + 2, Le_Block);

var touching_left_wall = place_meeting(x - 2, y, Le_Block);
var touching_right_wall = place_meeting(x + 2, y, Le_Block);

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
}

// Stop sliding when the key is released or the player leaves the ground
if (is_sliding && (!slide_held || !on_ground))
{
    is_sliding = false;
    slide_direction = 0;
}


// =====================================
// SLIDE SPRITE SWITCHING
// =====================================

if (is_sliding)
{
    if (slide_direction == 1)
    {
        // Sliding right
        sprite_index = Le_player_Sprite;
    }
    else if (slide_direction == -1)
    {
        // Sliding left
        sprite_index = Le_player_Sprite;
    }
}
else
{
    // Return to the normal sprite
    sprite_index = Le_player_Sprite;
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
    else if (touching_wall && wall_jumps_used < max_wall_jumps)
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