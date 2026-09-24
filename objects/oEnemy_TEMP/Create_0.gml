event_inherited();
// =====================================
// GROUND MOVEMENT
// =====================================

ground_move_speed = 120;

vertical_speed = 0;
gravity_force = 900;
maximum_fall_speed = 500;

ground_jump_speed = -330;

is_grounded = false;


// Moves horizontally and jumps if blocked
ground_move = function(_amount, _can_jump = true)
{
    var move_direction = sign(_amount);

    if (move_direction == 0)
    {
        return;
    }

    if (!place_meeting(x + _amount, y, o_Block))
    {
        x += _amount;
    }
    else if (_can_jump && is_grounded)
    {
        vertical_speed = ground_jump_speed;
    }
};