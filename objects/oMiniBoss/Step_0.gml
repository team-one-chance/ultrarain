if (variable_instance_exists(id, "train_departing") && train_departing)
{
    path_end();
    speed = 0;
    exit;
}
// Dev AI freeze keeps drawing and damage available.
if (variable_global_exists("dev_freeze_enemies") && global.dev_freeze_enemies) exit;

var dt = (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) / 1000000;
// Capture this before inherited Step decrements the timers.
var slam_locked = slam_stun_timer > 0 || slam_knockback_timer > 0;
// Parent Step has no hit-sprite/timer processing in the supplied version.
hit_timer = max(0, hit_timer - dt);

if (defend_sprite_timer > 0)
{
    defend_sprite_timer = max(
        0,
        defend_sprite_timer - dt
    );
}

normal_attack_cooldown = max(
    0,
    normal_attack_cooldown - dt
);

leap_cooldown = max(
    0,
    leap_cooldown - dt
);

// Knockback and the parent's stun cancel a mini-boss attack.
if (slam_locked || knockback_timer > 0 || attack_state == 5)
{
    miniboss_state = 0;
    miniboss_timer = 0;
    leap_horizontal_speed = 0;
    leap_aim_locked = false;
    leap_left_ground = false;
}

// While waiting nearby, stop the parent's chase so our slow pacing
// supplies the horizontal motion. The parent's gravity and collision run.
var nearby_player = instance_nearest(x, y, o_Player);
var nearby_body_center_x = (bbox_left + bbox_right) * 0.5;
var ready_to_pace =
    !slam_locked
    && miniboss_state == 0
    && nearby_player != noone
    && attack_state != 5
    && knockback_timer <= 0
    && place_meeting(x, y + ground_check_distance, o_Block)
    && abs(nearby_player.x - nearby_body_center_x) <= stand_range
    && !place_meeting(
        x + sign(nearby_player.x - nearby_body_center_x) * 4,
        y,
        o_Block
    )
    && abs(nearby_player.bbox_bottom - bbox_bottom)
        <= normal_attack_vertical_tolerance;

if (ready_to_pace && !stand_pacing)
{
    stand_pace_origin_x = x;
    stand_pace_direction = choose(-1, 1);
}
stand_pacing = ready_to_pace;

// During a mini-boss move, the parent still handles gravity,
// collision, hit effects, and stun, but does not chase or jump.
var saved_ground_move_speed = ground_move_speed;
var saved_normal_sprite = normal_sprite;
var saved_gravity_force = gravity_force;
var saved_maximum_fall_speed = maximum_fall_speed;

if (miniboss_state != 0 || ready_to_pace)
{
    ground_move_speed = 0;
}

// The parent's gravity and collision code still moves the boss vertically.
// Increase both gravity and the speed cap only on the way down.
if (miniboss_state == 3 && vertical_speed >= 0)
{
    gravity_force *= leap_fall_gravity_multiplier;
    maximum_fall_speed = leap_max_fall_speed;
}

// Parent Step selects normal_sprite each frame. Point it at the
// active attack sprite for this call so animations keep advancing
// instead of switching back and restarting every frame.
if (defend_sprite_timer > 0)
{
    normal_sprite = defend_sprite;
}
else if (miniboss_state == 1 || miniboss_state == 2)
{
    normal_sprite = normal_attack;
}
normal_sprite = vertical_speed >= 0
    ? hard_landing_sprite : jump_sprite;
{
    normal_sprite = (ready_to_pace || miniboss_state == 5)
        ? stand_sprite : walk_sprite;
}

// Follow the player's X while rising. Commit to the last observed X
// once descent begins, leaving a chance to dodge the slam.
if (!slam_locked && miniboss_state == 3 && attack_state != 5)
{
    if (!leap_aim_locked)
    {
        if (vertical_speed < 0 && nearby_player != noone)
        {
            leap_target_x = nearby_player.x;
        }
        else if (vertical_speed >= 0)
        {
            leap_aim_locked = true;
        }
    }

    var leap_remaining_x =
        leap_target_x - (bbox_left + bbox_right) * 0.5;
    var leap_max_step = leap_max_horizontal_speed * dt;
    var leap_move_x = clamp(
        leap_remaining_x,
        -leap_max_step,
        leap_max_step
    );
    leap_horizontal_speed = dt > 0 ? leap_move_x / dt : 0;

    if (leap_move_x != 0
        && !place_meeting(x + leap_move_x, y, o_Block))
    {
        x += leap_move_x;
    }
    else if (leap_move_x != 0)
    {
        leap_horizontal_speed = 0;
    }
}

event_inherited();
ground_move_speed = saved_ground_move_speed;
normal_sprite = saved_normal_sprite;
gravity_force = saved_gravity_force;
maximum_fall_speed = saved_maximum_fall_speed;

// Decide when the body and shield are allowed to turn together.
var player = instance_nearest(x, y, o_Player);
var body_center_x = (bbox_left + bbox_right) * 0.5;
var grounded_now = place_meeting(
    x,
    y + ground_check_distance,
    o_Block
);

var delayed_turn =
    attack_state != 5
    && knockback_timer <= 0
    && (
        miniboss_state == 1
        || miniboss_state == 2
        || miniboss_state == 5
        || (
            miniboss_state == 0
            && player != noone
            && grounded_now
            && abs(player.x - body_center_x) <= stand_range
            && abs(player.bbox_bottom - bbox_bottom)
                <= normal_attack_vertical_tolerance
        )
    );

if (player != noone)
{
    var desired_facing = sign(player.x - body_center_x);

    if (desired_facing == 0 || desired_facing == facing_direction)
    {
        stand_attack_turn_timer = stand_attack_turn_delay;
    }
    else if (delayed_turn)
    {
        stand_attack_turn_timer = max(
            0,
            stand_attack_turn_timer - dt
        );

        if (stand_attack_turn_timer <= 0)
        {
            facing_direction = desired_facing;
            stand_attack_turn_timer = stand_attack_turn_delay;
        }
    }
    else
    {
        facing_direction = desired_facing;
        stand_attack_turn_timer = stand_attack_turn_delay;
    }
}
else
{
    stand_attack_turn_timer = stand_attack_turn_delay;
}

if (slam_locked || attack_state == 5 || knockback_timer > 0)
{
    // Parent stun and knockback keep control this frame.
}
else
{
    switch (miniboss_state)
    {
        // =====================================
        // CHASE / CHOOSE NEXT ATTACK
        // =====================================
        case 0:
        {
            if (player == noone || !grounded_now)
            {
                break;
            }

            var player_distance = abs(player.x - body_center_x);
            var player_feet_difference =
                abs(player.bbox_bottom - bbox_bottom);

            // Outside this window, the boss continues its usual chase
            // or nearby pacing instead of starting a leap.
            if (
                leap_cooldown <= 0
                && player_distance >= leap_trigger_min_distance
                && player_distance <= leap_trigger_max_distance
                && player_feet_difference <= leap_vertical_tolerance
            )
            {
                facing_direction = sign(player.x - body_center_x);
                leap_target_x = player.x;
                leap_horizontal_speed = 0;
                leap_aim_locked = false;
                vertical_speed = leap_jump_speed;
                leap_left_ground = false;
                miniboss_state = 3;
                image_index = 0;
                break;
            }

            // Inside the waiting zone, pace until the normal attack
            // cooldown expires, then move toward the player's live position.
            if (
                player_distance <= stand_range
                && player_feet_difference
                    <= normal_attack_vertical_tolerance
            )
            {
                if (normal_attack_cooldown <= 0)
                {
                    miniboss_state = 5;
                    stand_pacing = false;
                }
                else if (ready_to_pace)
                {
                    var pace_next_x = x + stand_pace_direction
                        * stand_pace_speed * dt;

                    if (abs(pace_next_x - stand_pace_origin_x)
                        >= stand_pace_distance)
                    {
                        stand_pace_direction *= -1;
                        pace_next_x = x + stand_pace_direction
                            * stand_pace_speed * dt;
                    }

                    if (
                        !place_meeting(pace_next_x, y, o_Block)
                        && place_meeting(
                            pace_next_x,
                            y + ground_check_distance,
                            o_Block
                        )
                    )
                    {
                        x = pace_next_x;
                    }
                    else
                    {
                        stand_pace_direction *= -1;
                    }
                }
                break;
            }

            break;
        }

        // =====================================
        // APPROACH FOR NORMAL ATTACK
        // =====================================
        case 5:
        {
            if (player == noone || !grounded_now)
            {
                miniboss_state = 0;
                break;
            }

            var approach_direction = sign(player.x - body_center_x);
            var approach_feet_difference =
                abs(player.bbox_bottom - bbox_bottom);

            if (approach_feet_difference
                > normal_attack_vertical_tolerance)
            {
                miniboss_state = 0;
                break;
            }

            if (abs(player.x - body_center_x) <= normal_attack_range)
            {
                miniboss_state = 1;
                miniboss_timer = normal_attack_windup;
                image_index = 0;
                break;
            }

            var approach_next_x = x + approach_direction
                * normal_attack_approach_speed * dt;

            if (
                !place_meeting(approach_next_x, y, o_Block)
                && place_meeting(
                    approach_next_x,
                    y + ground_check_distance,
                    o_Block
                )
            )
            {
                x = approach_next_x;
            }
            else
            {
                // Give the parent's normal chase another chance if
                // an obstacle blocks this straight approach.
                miniboss_state = 0;
            }
            break;
        }

        // =====================================
        // NORMAL ATTACK: HIT ONCE AFTER WINDUP
        // =====================================
        case 1:
        {
            miniboss_timer -= dt;

            if (miniboss_timer <= 0)
            {
                var hit_left;
                var hit_right;

                if (facing_direction > 0)
                {
                    hit_left = bbox_right;
                    hit_right = bbox_right + normal_attack_range;
                }
                else
                {
                    hit_left = bbox_left - normal_attack_range;
                    hit_right = bbox_left;
                }

                var target = collision_rectangle(
                    hit_left,
                    bbox_top,
                    hit_right,
                    bbox_bottom,
                    o_Player,
                    false,
                    true
                );

                if (target != noone)
                {
                    miniboss_damage_player(
                        target,
                        normal_attack_damage
                    );
                }

                miniboss_state = 2;
                miniboss_timer = normal_attack_recovery;
                normal_attack_cooldown = random_range(
                    normal_attack_cooldown_min,
                    normal_attack_cooldown_max
                );
            }

            break;
        }

        case 2:
        {
            miniboss_timer -= dt;

            if (miniboss_timer <= 0)
            {
                miniboss_state = 0;
            }

            break;
        }

        // =====================================
        // LEAP: ONE HIT WHEN GROUND IS REACHED
        // =====================================
        case 3:
        {
            if (!grounded_now)
            {
                leap_left_ground = true;
            }

            if (
                leap_left_ground
                && grounded_now
                && vertical_speed >= 0
            )
            {
                var landing_target = collision_rectangle(
                    bbox_left - leap_landing_range,
                    bbox_bottom - leap_landing_height,
                    bbox_right + leap_landing_range,
                    bbox_bottom + ground_check_distance,
                    o_Player,
                    false,
                    true
                );

                if (landing_target != noone)
                {
                    miniboss_damage_player(
                        landing_target,
                        leap_damage
                    );
                }

                leap_horizontal_speed = 0;
                leap_aim_locked = false;
                leap_left_ground = false;
                miniboss_state = 4;
                miniboss_timer = leap_recovery;
                leap_cooldown = random_range(
                    leap_cooldown_min,
                    leap_cooldown_max
                );
            }

            break;
        }

        case 4:
        {
            miniboss_timer -= dt;

            if (miniboss_timer <= 0)
            {
                miniboss_state = 0;
            }

            break;
        }
    }
}

// The parent's Step event chooses hit/stun/normal sprites.
// Set the sprite once when an attack starts in this frame.
if (slam_locked || attack_state == 5)
{
    sprite_index = stun_sprite;
}
else if (defend_sprite_timer > 0)
{
    sprite_index = defend_sprite;
}
else if (hit_timer > 0)
{
    sprite_index = hit_sprite;
}
else if (miniboss_state == 1 || miniboss_state == 2)
{
    if (sprite_index != normal_attack)
    {
        sprite_index = normal_attack;
    }
}
else if (miniboss_state == 3)
{
    var leap_sprite = vertical_speed >= 0
        ? hard_landing_sprite : jump_sprite;

    if (sprite_index != leap_sprite)
    {
        sprite_index = leap_sprite;
    }
}
else if (miniboss_state == 0 || miniboss_state == 4)
{
    var waiting_near_player =
        player != noone
        && grounded_now
        && abs(player.x - (bbox_left + bbox_right) * 0.5)
            <= stand_range
        && abs(player.bbox_bottom - bbox_bottom)
            <= normal_attack_vertical_tolerance;

    normal_sprite = waiting_near_player
        ? stand_sprite : walk_sprite;

    if (sprite_index != normal_sprite)
    {
        sprite_index = normal_sprite;
    }
}
