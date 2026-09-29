// =====================================
// UNIQUE MOVEMENT PATTERN MUST BE KEPT
// =====================================
// =====================================
// UNIQUE MOVEMENT PATTERN
// =====================================

var dt = delta_time / 1000000;

var player = instance_nearest(
    x,
    y,
    o_Player
);

if (player != noone)
{
    // Position the drone initially approaches
    var approach_x = player.x;
    var approach_y = player.y - 140;

    var approach_distance = point_distance(
        x,
        y,
        approach_x,
        approach_y
    );


// =====================================
// APPROACH PLAYER WITH WEAVING
// =====================================

// Centre of the drone's desired combat area
/*var approach_x = player.x;
var approach_y = player.y - 140;

var approach_distance = point_distance(
    x,
    y,
    approach_x,
    approach_y
);*/

if (!drone_engaged)
{
    // Advance the chase pattern
    chase_angle += (
        chase_pattern_speed
        * chase_direction
        * dt
    );


    // Occasionally alter the pattern
    chase_change_timer -= dt;

    if (chase_change_timer <= 0)
    {
        if (irandom(2) == 0)
        {
            chase_direction *= -1;
        }

        chase_pattern_speed = random_range(120, 190);
        chase_radius_x = random_range(60, 100);
        chase_radius_y = random_range(20, 50);

        chase_change_timer = random_range(0.8, 1.8);
    }


    // Moving destination around the combat position
    var chase_target_x =
        approach_x
        + lengthdir_x(
            chase_radius_x,
            chase_angle
        );

    var chase_target_y =
        approach_y
        + lengthdir_y(
            chase_radius_y,
            chase_angle * 2
        );

    chase_target_x = clamp(
        chase_target_x,
        16,
        room_width - 16
    );

    chase_target_y = clamp(
        chase_target_y,
        16,
        room_height - 16
    );


    // Continue chasing until near the combat area
    if (approach_distance > 70)
    {
        repath_timer -= dt;

        if (repath_timer <= 0)
        {
            var path_found = mp_grid_path(
                nav_grid,
                enemy_path,
                x,
                y,
                chase_target_x,
                chase_target_y,
                true
            );

            if (path_found)
            {
                path_start(
                    enemy_path,
                    2.5,
                    path_action_stop,
                    false
                );
            }

            repath_timer = 0.08;
        }
    }
    else
    {
        path_end();

        drone_engaged = true;
        repath_timer = 0;

        orbit_angle = point_direction(
            player.x,
            player.y - orbit_height,
            x,
            y
        );
    }
}


    // =====================================
    // COMBAT ORBIT
    // =====================================

    else
    {
        // Return to chase mode if the player escapes
        var player_distance = point_distance(
            x,
            y,
            player.x,
            player.y
        );

        if (player_distance > 320)
        {
            path_end();

            drone_engaged = false;
            repath_timer = 0;
        }
        else
        {
            // Move continuously around the player
            orbit_angle += (
                orbit_speed
                * orbit_direction
                * dt
            );


            // Occasionally change the pattern
            orbit_change_timer -= dt;

            if (orbit_change_timer <= 0)
            {
                // Sometimes reverse direction
                if (irandom(1) == 0)
                {
                    orbit_direction *= -1;
                }

                orbit_speed = random_range(110, 180);

                orbit_radius_x = random_range(80, 140);
                orbit_radius_y = random_range(30, 65);
                orbit_height = random_range(140, 200);
				//increase the above values for higher orbit height

                orbit_change_timer = random_range(1.2, 2.4);
            }


            // Horizontal orbit plus faster vertical movement
            // creates a loose figure-eight
            var target_x =
                player.x
                + lengthdir_x(
                    orbit_radius_x,
                    orbit_angle
                );

            var target_y =
                player.y
                - orbit_height
                + lengthdir_y(
                    orbit_radius_y,
                    orbit_angle * 2
                );


            // Keep target inside the room
            target_x = clamp(
                target_x,
                16,
                room_width - 16
            );

            target_y = clamp(
                target_y,
                16,
                room_height - 16
            );


            // Frequently update the route to the moving target
            repath_timer -= dt;

            if (repath_timer <= 0)
            {
                var orbit_path_found = mp_grid_path(
                    nav_grid,
                    enemy_path,
                    x,
                    y,
                    target_x,
                    target_y,
                    true
                );

                if (orbit_path_found)
                {
                    path_start(
                        enemy_path,
                        3,
                        path_action_stop,
                        false
                    );
                }
                else
                {
                    // Try the opposite direction if the target
                    // landed somewhere unreachable
                    orbit_direction *= -1;
                }

                repath_timer = 0.08;
            }
        }
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
        oEnemyDroneBullet
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