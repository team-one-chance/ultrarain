var player = instance_nearest(x, y, o_Player);

if (player != noone)
{
    var distance = point_distance(
        x,
        y,
        player.x,
        player.y - 40
    );

    if (distance > 3)
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
                player.y - 140,
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

    sprite_index = sDrone_hit;
}
else
{
    sprite_index = normal_sprite;
}

