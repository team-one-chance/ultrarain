// =====================================
// KNOCKBACK OR NORMAL MOVEMENT
// =====================================

if (knockback_timer > 0)
{
    knockback_timer -= delta_time / 1000000;

    var move_x = knockback_x * 0.2;
    var move_y = knockback_y * 0.2;

    if (!place_meeting(x + move_x, y, o_Block))
    {
        x += move_x;
    }

    if (!place_meeting(x, y + move_y, o_Block))
    {
        y += move_y;
    }

    knockback_x *= 0.8;
    knockback_y *= 0.8;
}
else
{
    // =====================================
    // YOUR NORMAL CHASE/PATHFINDING CODE
    // GOES HERE
    // =====================================
}



var player = instance_nearest(x, y, o_Player);

if (player != noone)
{
    var distance = point_distance(
        x,
        y,
        player.x,
        player.y - 40
    );

    if (distance > 30)
    {
        repath_timer -= delta_time / 1000000;

        if (repath_timer <= 0)
        {
            var path_found = mp_grid_path(
                nav_grid,
                enemy_path,
                x,
                y,
                player.x,
                player.y - 40,
                true
            );

            if (path_found)
            {
                path_start(
                    enemy_path,
                    2,
                    path_action_stop,
                    false
                );
            }

            repath_timer = 0.15;
        }
    }
    else
    {
        path_end();
    }
}




// =====================================
// HIT SPRITE
// =====================================

if (hit_timer > 0)
{
    hit_timer -= delta_time / 1000000;
    sprite_index = hit_sprite;
}
else
{
    sprite_index = normal_sprite;
}
