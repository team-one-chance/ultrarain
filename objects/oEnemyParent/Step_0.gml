// Dev AI freeze keeps drawing and damage available.
if (variable_global_exists("dev_freeze_enemies") && global.dev_freeze_enemies) exit;

var dt = (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) / 1000000;
var parent_slam_locked = enemy_slam_step(dt);

// =====================================
// KNOCKBACK //UNIQUE TO ENEMYTEMP
// =====================================

if (parent_slam_locked)
{
    // Slam movement already ran. Skip normal movement this frame.
}
else if (knockback_timer > 0)
{
    path_end();

    knockback_timer -= dt;

    var move_x =
        knockback_x * knockback_move_multiplier;

    var move_y =
        knockback_y * knockback_move_multiplier;

    if (!place_meeting(x + move_x, y, o_Block))
    {
        x += move_x;
    }

    if (!place_meeting(x, y + move_y, o_Block))
    {
        y += move_y;
    }

    knockback_x *= knockback_decay;
    knockback_y *= knockback_decay;
}


// =====================================
// STUN //UNIQUE TO ENEMYTEMP
// =====================================

else if (attack_state == 5)
{
    path_end();

    stun_timer -= dt;

    if (stun_timer <= 0)
    {
        stun_timer = 0;
        attack_state = 0;
    }
}


// =====================================
// NORMAL GROUND CHASE //VERY LIKELY GLOBAL 
// =====================================

else
{
    // Ground enemies must never follow paths directly.
    path_end();

    is_grounded = place_meeting(
        x,
        y + ground_check_distance,
        o_Block
    );

    var player = instance_nearest(x, y, o_Player);

    if (player != noone)
    {
        var chase_direction =
            sign(player.x - x);

        var chase_move =
            chase_direction
            * ground_move_speed
            * dt;

        if (chase_direction != 0)
        {
            if (!place_meeting(
                x + chase_move,
                y,
                o_Block
            ))
            {
                x += chase_move;
            }
            else if (is_grounded)
            {
                vertical_speed =
                    ground_jump_speed;
            }
        }
    }
}


// =====================================
// GRAVITY AND VERTICAL COLLISION //LIKELY UNIQUE TO ENEMYTEMP
// =====================================

is_grounded = place_meeting(
    x,
    y + ground_check_distance,
    o_Block
);

if (is_grounded && vertical_speed > 0)
{
    vertical_speed = 0;
}
else
{
    vertical_speed += gravity_force * dt;

    vertical_speed = min(
        vertical_speed,
        maximum_fall_speed
    );
}

var vertical_move =
    vertical_speed * dt;

if (vertical_move != 0)
{
    if (place_meeting(
        x,
        y + vertical_move,
        o_Block
    ))
    {
        var vertical_direction =
            sign(vertical_move);

        while (!place_meeting(
            x,
            y + vertical_direction,
            o_Block
        ))
        {
            y += vertical_direction;
        }

        vertical_speed = 0;
    }
    else
    {
        y += vertical_move;
    }
}


