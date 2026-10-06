var dt = delta_time / 1000000;

// Capture the state BEFORE movement/timers update this frame.
crowd_spacing_paused = !crowd_can_separate();
	
var slam_locked = enemy_slam_step(dt);

if (post_climb_attack_timer > 0)
{
    post_climb_attack_timer = max(
        0,
        post_climb_attack_timer - dt
    );
}


// =====================================
// KNOCKBACK
// =====================================

if (slam_locked)
{
    // Slam movement already ran. Skip normal AI this frame.
}
else if (knockback_timer > 0)
{
    path_end();
    is_climbing = false;

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

    attack_shake_x = 0;
    attack_shake_y = 0;
}


// =====================================
// NORMAL AI
// =====================================

else
{
    // Ground enemies must never follow paths directly
    path_end();

    is_grounded =
        place_meeting(
            x,
            y + ground_check_distance,
            o_Block
        );


    // =====================================
    // WALL CLIMBING
    // =====================================

    if (is_climbing)
    {
        path_end();
        vertical_speed = 0;

        // Climbing owns the enemy until it has fully finished.
        post_climb_attack_timer =
            post_climb_attack_delay;

        var climb_move =
            climb_speed * dt;

        var touching_climb_wall =
            place_meeting(
                x
                + climb_direction
                * climb_wall_check_distance,
                y,
                o_Block
            );

        // The enemy may only climb while a wall is beside it.
        if (touching_climb_wall)
        {
            if (!place_meeting(
                x,
                y - climb_move,
                o_Block
            ))
            {
                y -= climb_move;
            }
            else
            {
                // Something above blocks the climb.
                is_climbing = false;
            }
        }
        else
{
    var mantle_move =
        climb_direction
        * climb_mantle_distance;

    if (!place_meeting(
        x + mantle_move,
        y,
        o_Block
    ))
    {
        x += mantle_move;

        // Only finish climbing after the mantle succeeds.
        is_climbing = false;

        post_climb_attack_timer =
            post_climb_attack_delay;
    }
    else
    {
        // The enemy is not high enough to clear the platform edge.
        // Continue moving upward instead of repeatedly restarting.
        if (!place_meeting(
            x,
            y - climb_move,
            o_Block
        ))
        {
            y -= climb_move;
        }
        else
        {
            // Blocked above as well: cancel climbing.
            is_climbing = false;
        }
    }
}
    }

    // Climbing may have moved the enemy onto or beyond a platform.
    // Refresh this now so the attack code never uses the old value.
    is_grounded = place_meeting(
        x,
        y + ground_check_distance,
        o_Block
    );

    var player = instance_nearest(x, y, o_Player);

    if (player != noone)
    {
        switch (attack_state)
        {
            // =====================================
            // NORMAL CHASE AND ROCKING ATTACK
            // =====================================

            case 0:
            {
                attack_cooldown -= dt;

                // Compare X normally and Y using both characters' feet.
                var player_x_distance =
                    abs(player.x - x);

                var player_y_distance =
                    abs(player.bbox_bottom - bbox_bottom);

                // Do not let either attack sequence take control while
                // climbing, airborne, or still settling after a climb.
                if (
                    is_climbing
                    || !is_grounded
                    || post_climb_attack_timer > 0
                )
                {
                    attack_rocking = false;
                    break;
                }

                // Charge attack is ready
                if (
                    attack_cooldown <= 0
                    && player_x_distance
                        <= attack_trigger_x_distance
                    && player_y_distance
                        <= attack_vertical_tolerance
                )
                {
                    path_end();

                    attack_rocking = false;

                    attack_stop_distance = random_range(
                        attack_stop_distance_min,
                        attack_stop_distance_max
                    );

                    attack_side = sign(x - player.x);

                    if (attack_side == 0)
                    {
                        attack_side = choose(-1, 1);
                    }

                    attack_state = 1;
                    repath_timer = 0;

                    break;
                }


                


                // =====================================
                // ENTER ROCKING ATTACK
                // =====================================

                if (!attack_rocking)
                {
                    if (
                        player_x_distance
                            > attack_rock_enter_x_distance
                        || player_y_distance
                            > attack_vertical_tolerance
                        || is_climbing
                        || !is_grounded
                    )
                    {
                        var chase_direction =
                            sign(player.x - x);

                        // If directly below the player, pick one direction
                        // and keep moving until a climbable wall is reached.
                        if (chase_direction == 0)
                        {
                            if (attack_side == 0)
                            {
                                attack_side = choose(-1, 1);
                            }

                            chase_direction = attack_side;
                        }

                        var chase_step = ground_move_speed * dt;
var chase_move = chase_direction * chase_step;

// On the same floor, don't overshoot the player's X position.
if (player_y_distance <= attack_vertical_tolerance)
{
    chase_move = chase_direction * min(
        chase_step,
        abs(player.x - x)
    );
}
                        if (!is_climbing)
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
                                // A real wall was reached: begin climbing it.
                                is_climbing = true;
                                climb_direction = chase_direction;
                                vertical_speed = 0;
                                image_index = 0;
                            }
                        }
                    }
                    else
                    {
                        path_end();

                        attack_rocking = true;
                        image_index = 0;

                        attack_rock_side =
                            choose(-1, 1);

                        attack_rock_distance = random_range(
                            attack_rock_distance_min,
                            attack_rock_distance_max
                        );

                        attack_rock_speed = random_range(
                            attack_rock_speed_min,
                            attack_rock_speed_max
                        );

                        attack_rock_delay = random_range(
                            attack_rock_start_delay_min,
                            attack_rock_start_delay_max
                        );

                        attack_rock_offset = random_range(
                            attack_rock_offset_min,
                            attack_rock_offset_max
                        );
                    }
                }


                // =====================================
                // ROCK BACK AND FORTH
                // =====================================

                else
                {
                    // Player escaped
                    if (
                        player_x_distance
                            > attack_rock_exit_x_distance
                        || player_y_distance
                            > attack_vertical_tolerance
                    )
                    {
                        attack_rocking = false;
                        repath_timer = 0;
                    }
                    else
                    {
                        path_end();

                        if (attack_rock_delay > 0)
                        {
                            attack_rock_delay -= dt;
                        }
                        else
                        {
                            var rock_target_x =
                                player.x
                                + attack_rock_offset
                                + attack_rock_side
                                * attack_rock_distance;

                            var rock_move =
                                attack_rock_speed
                                * dt;

                            var rock_difference =
                                rock_target_x - x;

                            if (abs(rock_difference) <= rock_move)
                            {
                                x = rock_target_x;

                                attack_rock_side *= -1;
                                image_index = 0;

                                attack_rock_distance = random_range(
                                    attack_rock_distance_min,
                                    attack_rock_distance_max
                                );

                                attack_rock_speed = random_range(
                                    attack_rock_speed_min,
                                    attack_rock_speed_max
                                );

                                attack_rock_delay = random_range(
                                    attack_rock_turn_delay_min,
                                    attack_rock_turn_delay_max
                                );

                                attack_rock_offset = random_range(
                                    attack_rock_offset_min,
                                    attack_rock_offset_max
                                );
                            }
                            else
                            {
                                var rock_move_x =
                                    sign(rock_difference)
                                    * rock_move;

                                if (!place_meeting(
                                    x + rock_move_x,
                                    y,
                                    o_Block
                                ))
                                {
                                    x += rock_move_x;
                                }
                                else
                                {
                                    attack_rock_side *= -1;
                                    image_index = 0;

                                    attack_rock_delay = random_range(
                                        attack_rock_blocked_delay_min,
                                        attack_rock_blocked_delay_max
                                    );
                                }
                            }
                        }
                    }
                }

                break;
            }


            // =====================================
            // MOVE TO ATTACK DISTANCE
            // =====================================

            case 1:
            {
                // Attack positioning is not allowed to overlap climbing
                // or continue after the enemy has lost the floor.
                if (
                    is_climbing
                    || !is_grounded
                    || post_climb_attack_timer > 0
                )
                {
                    attack_state = 0;
                    attack_rocking = false;
                    break;
                }

                // Stop preparing the charge if the player changes floors.
                if (
                    abs(player.bbox_bottom - bbox_bottom)
                    > attack_vertical_tolerance
                )
                {
                    attack_state = 0;
                    attack_rocking = false;
                    break;
                }

                var attack_position_x =
                    player.x
                    + attack_side
                    * attack_stop_distance;

                var position_distance =
                    abs(attack_position_x - x);

                if (
                    position_distance
                        <= attack_position_tolerance
                    && !is_climbing
                    && is_grounded
                )
                {
                    path_end();

                    attack_origin_x = x;
                    attack_origin_y = y;

                    attack_charge_timer =
                        attack_charge_duration;

                    attack_state = 2;
                }
                else
                {
                    var position_direction =
                        sign(attack_position_x - x);

                    var position_move =
                        position_direction
                        * ground_move_speed
                        * dt;

                    if (!is_climbing)
                    {
                        var position_blocked = place_meeting(
                            x + position_move,
                            y,
                            o_Block
                        );

                        var position_has_floor = place_meeting(
                            x + position_move,
                            y + ground_check_distance,
                            o_Block
                        );

                        if (
                            !position_blocked
                            && position_has_floor
                        )
                        {
                            x += position_move;
                        }
                        else if (position_blocked && is_grounded)
                        {
                            is_climbing = true;
                            climb_direction = position_direction;
                            vertical_speed = 0;
                            image_index = 0;

                            // Climbing takes priority. The attack may be
                            // reconsidered only after the climb completes.
                            post_climb_attack_timer =
                                post_climb_attack_delay;

                            attack_state = 0;
                            attack_rocking = false;
                        }
                        else
{
    // The charge position is beyond the platform edge.
    attack_state = 0;
    attack_rocking = false;

    // Prevent immediately retrying the same impossible attack.
    attack_cooldown = random_range(
        attack_cooldown_min,
        attack_cooldown_max
    );
}
                    }
                }

                break;
            }


            // =====================================
            // CHARGE INDICATOR
            // =====================================

            case 2:
            {
                path_end();

                attack_charge_timer -= dt;

                // Visual-only shaking
                attack_shake_x = random_range(
                    -attack_shake_x_amount,
                    attack_shake_x_amount
                );

                attack_shake_y = random_range(
                    -attack_shake_y_amount,
                    attack_shake_y_amount
                );

                if (attack_charge_timer <= 0)
                {
                    attack_shake_x = 0;
                    attack_shake_y = 0;

                    var dash_direction =
                        sign(player.x - x);

                    if (dash_direction == 0)
                    {
                        dash_direction = attack_side * -1;
                    }

                    attack_side = dash_direction;

                    // Slightly overshoot the player's position
                    attack_target_x =
                        player.x
                        + dash_direction
                        * attack_dash_overshoot;
						
						attack_hit_player = false;
                    attack_state = 3;
                }

                break;
            }


           // =====================================
            // DASH: RETURN ONLY ON A MISS
            // =====================================
            case 3:
            {
                var _dash_finished = false;
                var _dash_distance = max(0, attack_dash_speed * dt);

                attack_register_dash_hit(player);

                // Sweep in <=1px increments to detect contact and walls.
                var _dash_steps = ceil(_dash_distance);

                if (_dash_steps > 0)
                {
                    var _dash_step = _dash_distance / _dash_steps;

                    repeat (_dash_steps)
                    {
                        var _target_distance =
                            (attack_target_x - x) * attack_side;

                        if (_target_distance <= 0)
                        {
                            _dash_finished = true;
                            break;
                        }

                        var _move_x = attack_side
                            * min(_dash_step, _target_distance);

                        if (place_meeting(x + _move_x, y, o_Block))
                        {
                            _dash_finished = true;
                            break;
                        }

                        x += _move_x;

                        // First contact extends the destination once.
                        attack_register_dash_hit(player);

                        if ((attack_target_x - x) * attack_side <= 0)
                        {
                            _dash_finished = true;
                            break;
                        }
                    }
                }

                if (_dash_finished)
                {
                    attack_shake_x = 0;
                    attack_shake_y = 0;

                    if (attack_hit_player)
                    {
                        // Successful hit: stay at the new position.
                        // Resume normal AI with the usual cooldown.
                        attack_rocking = false;
                        attack_state = 0;
                        repath_timer = 0;

                        attack_cooldown = random_range(
                            attack_cooldown_min,
                            attack_cooldown_max
                        );
                    }
                    else
                    {
                        // Miss: keep the existing fly-back sequence.
                        attack_state = 4;
                    }
                }

                break;
            }


        
            // =====================================
            // FLY BACK TO CHARGE POSITION
            // =====================================

            case 4:
            {
                is_climbing = false;
                vertical_speed = 0;

                var return_distance = point_distance(
                    x,
                    y,
                    attack_origin_x,
                    attack_origin_y
                );

                var return_move =
                    attack_return_speed * dt;

                if (return_distance <= return_move)
                {
                    x = attack_origin_x;
                    y = attack_origin_y;

                    attack_state = 0;

                    attack_cooldown = random_range(
                        attack_cooldown_min,
                        attack_cooldown_max
                    );
                }
                else
                {
                    var return_direction = point_direction(
                        x,
                        y,
                        attack_origin_x,
                        attack_origin_y
                    );

                    x += lengthdir_x(
                        return_move,
                        return_direction
                    );

                    y += lengthdir_y(
                        return_move,
                        return_direction
                    );
                }

                break;
            }

            // =====================================
            // STUN AFTER PARRY
            // =====================================

            case 5:
            {
                // Remain still after the knockback finishes
                path_end();
                is_climbing = false;

                stun_timer -= dt;

                if (stun_timer <= 0)
                {
                    stun_timer = 0;

                    // Resume chasing from the current position.
                    // Do not return to attack_origin.
                    attack_state = 0;

                    attack_cooldown = random_range(
                        attack_cooldown_min,
                        attack_cooldown_max
                    );
                }

                break;
            }

        } // closes switch (attack_state)
    }     // closes if (player != noone)
    else
    {
        path_end();

        attack_shake_x = 0;
        attack_shake_y = 0;
    }
}         // closes normal AI else


// =====================================
// GRAVITY AND VERTICAL COLLISION
// =====================================

is_grounded = place_meeting(
    x,
    y + ground_check_distance,
    o_Block
);

if (is_climbing || attack_state == 4)
{
    vertical_speed = 0;
}
else
{
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
}

// =====================================
// SPRITE STATE
// =====================================

if (hit_timer > 0)
{
    hit_timer -= dt;
    sprite_index = hit_sprite;
}
else if (slam_locked)
{
    sprite_index = stun_sprite;
}
else if (attack_state == 5)
{
    sprite_index = stun_sprite;
}
else if (attack_state == 2 || attack_state == 3)
{
    sprite_index = attack_sprite;
}
else if (attack_state == 0 && attack_rocking)
{
    sprite_index = bite_sprite;
}
else if (is_climbing)
{
    sprite_index = climb_sprite;
}
else
{
    sprite_index = normal_sprite;
}
