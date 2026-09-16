// Keep player upright
phy_angular_velocity = 0;
phy_rotation = 0;

// Horizontal movement
var move = 0;

if (keyboard_check(vk_right) || keyboard_check(ord("D")))
{
    move += 1;
}

if (keyboard_check(vk_left) || keyboard_check(ord("A")))
{
    move -= 1;
}

phy_speed_x = move * 3;

// Check if the player is touching the ground
var on_ground = place_meeting(x, y + 2, Le_Block);

// Jump
if (on_ground)
{
    if (keyboard_check_pressed(ord("W"))
    || keyboard_check_pressed(vk_up)
    || keyboard_check_pressed(vk_space))
    {
        phy_speed_y = -2.5;
    }
}