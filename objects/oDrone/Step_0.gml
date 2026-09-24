// =====================================
// UNIQUE MOVEMENT PATTERN MUST BE KEPT
// =====================================
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
// UNIQUE HIT SPRITE MUST BE KEPT
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

// =====================================
// UNIQUE SHOOT SYSTEM MUST BE KEPT
// =====================================

if (shoot_timer > 0)
{
    shoot_timer -= delta_time / 1000000;
}

var shoot_player = instance_nearest(x, y, o_Player);

if (shoot_player != noone && shoot_timer <= 0)
{
    var bullet = instance_create_depth(
        x,
        y,
        depth - 1,
        oEnemyBullet
    );

    bullet.direction = point_direction(
        x,
        y,
        shoot_player.x,
        shoot_player.y
    );

    shoot_timer = shoot_cooldown;

    show_debug_message("ENEMY FIRED BULLET");
}