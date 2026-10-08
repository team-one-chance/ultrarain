// Dev AI freeze keeps drawing and damage available.
if (variable_global_exists("dev_freeze_enemies") && global.dev_freeze_enemies) exit;

// =====================================
// UNIQUE MOVEMENT PATTERN MUST BE KEPT
// =====================================
// =====================================
// UNIQUE MOVEMENT PATTERN
// =====================================

var dt = (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) / 1000000;
var slam_locked = enemy_slam_step(dt);
var player = instance_nearest(
    x,
    y,
    o_Player
);

if (player != noone && !slam_locked)
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
    hit_timer -= (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) / 1000000;

    sprite_index = sDrone_hit;
}
else
{
    sprite_index = normal_sprite;
}

/*// =====================================
// UNIQUE SHOOT SYSTEM MUST BE KEPT
// =====================================

if (shoot_timer > 0)
{
    shoot_timer -= (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) / 1000000;
}

var shoot_player = instance_nearest(x, y, o_Player);

if (shoot_player != noone && shoot_timer <= 0 && !slam_locked)
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
}*/
// =====================================
// CHARGED, COORDINATED HITSCAN BURST
// =====================================

drone_attack_cooldown = max(
    0, drone_attack_cooldown - dt
);

drone_turn_wait = max(
    0, drone_turn_wait - dt
);

var _can_attack = false;

if (player != noone && !slam_locked)
{
    var _cx = (bbox_left + bbox_right) * 0.5;
    var _cy = (bbox_top + bbox_bottom) * 0.5;

    var _px = (player.bbox_left + player.bbox_right) * 0.5;
    var _py = (player.bbox_top + player.bbox_bottom) * 0.5;

    var _distance = point_distance(_cx, _cy, _px, _py);

    if (_distance <= drone_attack_distance)
    {
        var _angle = point_direction(_cx, _cy, _px, _py);

        var _sight = drone_trace(
            _cx, _cy, _angle, _distance, false
        );

        _can_attack = (_sight.hit == noone);
    }
}

drone_ready =
    _can_attack
    && drone_fire_state == 0
    && drone_attack_cooldown <= 0
    && drone_turn_wait <= 0;

// Losing sight or getting slammed interrupts the attack.
if (drone_fire_state != 0 && !_can_attack)
{
    drone_fire_state = 0;
    drone_ready = false;

    drone_attack_cooldown = random_range(
        drone_recovery_min,
        drone_recovery_max
    );

    var _cancel_gap = drone_turn_gap;

    with (oDrone)
    {
        drone_turn_wait = max(
            drone_turn_wait, _cancel_gap
        );
    }
}

// Randomly give one eligible drone the next turn.
if (drone_ready)
{
    var _busy = false;
    var _candidates = [];

    for (var _i = 0; _i < instance_number(oDrone); _i++)
    {
        var _drone = instance_find(oDrone, _i);

        if (_drone.drone_fire_state != 0)
        {
            _busy = true;
            break;
        }

        if (_drone.drone_ready
        && _drone.drone_turn_wait <= 0
        && _drone.slam_knockback_timer <= 0
        && _drone.slam_stun_timer <= 0)
        {
            array_push(_candidates, _drone);
        }
    }

    if (!_busy && array_length(_candidates) > 0)
    {
        var _chosen = _candidates[
            irandom(array_length(_candidates) - 1)
        ];

        _chosen.drone_fire_state = 1;
        _chosen.drone_ready = false;

        _chosen.drone_charge_timer =
            _chosen.drone_charge_duration;
    }
}


// =====================================
// AIM ROTATION
// =====================================

// Track during movement, charging, and firing.
// Freeze aim during the final dodge window before each shot.
var _aim_frozen =
    (drone_fire_state == 1
        && drone_charge_timer <= drone_aim_lock_duration)
    ||
    (drone_fire_state == 2
        && drone_shot_timer <= drone_aim_lock_duration);

if (player != noone && !slam_locked && !_aim_frozen)
{
    var _desired_angle = point_direction(
        (bbox_left + bbox_right) * 0.5,
        (bbox_top + bbox_bottom) * 0.5,
        (player.bbox_left + player.bbox_right) * 0.5,
        (player.bbox_top + player.bbox_bottom) * 0.5
    );

    // Shortest signed turn, including across 0/360 degrees.
    var _angle_difference =
        ((_desired_angle - drone_shot_angle + 540) mod 360) - 180;

    var _maximum_turn = drone_aim_turn_speed * dt;

    drone_shot_angle = (
        drone_shot_angle
        + clamp(
            _angle_difference,
            -_maximum_turn,
            _maximum_turn
        )
        + 360
    ) mod 360;
}

// Only the unpaused portion of this frame advances attack timers.
var _paused_time = min(dt, drone_shot_pause_timer);
var _attack_dt = dt - _paused_time;

drone_shot_pause_timer = max(
    0, drone_shot_pause_timer - dt
);

// =====================================
// INITIAL CHARGE
// =====================================

if (drone_fire_state == 1)
{
    drone_charge_timer = max(
        0, drone_charge_timer - _attack_dt
    );

    if (drone_charge_timer <= 0)
    {
        drone_fire_state = 2;
        drone_shots_left = drone_burst_count;
        drone_shot_timer = 0;
    }
}

// =====================================
// THREE-SHOT BURST
// =====================================

if (drone_fire_state == 2)
{
    drone_shot_timer = max(
        0, drone_shot_timer - _attack_dt
    );

    if (drone_shot_timer <= 0 && _attack_dt > 0)
    {
        // Fire along the current aim, even if it hasn't caught up.
        drone_fire_shot();
        drone_shots_left -= 1;

        if (drone_shots_left > 0)
        {
            drone_shot_timer = drone_shot_interval;
        }
        else
        {
            drone_fire_state = 0;
            drone_ready = false;

            drone_attack_cooldown = random_range(
                drone_recovery_min,
                drone_recovery_max
            );

            var _finished_gap = drone_turn_gap;

            with (oDrone)
            {
                drone_turn_wait = max(
                    drone_turn_wait, _finished_gap
                );
            }
        }
    }
}