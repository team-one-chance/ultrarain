if (variable_instance_exists(id, "train_departing") && train_departing)
{
    path_end();
    speed = 0;
    exit;
}
// Dev AI freeze keeps drawing and damage available.
if (variable_global_exists("dev_freeze_enemies") && global.dev_freeze_enemies) exit;

var dt = (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) / 1000000;
var scout_start_x = x;
// Count gameplay time even while knockback suppresses the stopping animation.
scout_parry_grace_timer = attack_state == 4
    ? max(0, scout_parry_grace_timer - dt) : 0;
scout_roll_spacing_timer = max(0, scout_roll_spacing_timer - dt);
scout_animation_time += dt;
if (scout_hit_pending && sprite_index == hit_sprite) scout_hit_elapsed += dt;
if (scout_animation_finished(s_Scout_attackEnter)) scout_attack_enter_complete = true;
attack_bite_damage_timer = max(0, attack_bite_damage_timer - dt);
var scout_parry_locked = attack_state == 5 && stun_timer > 0;
var scout_stunned = scout_parry_locked || slam_stun_timer > 0 || slam_knockback_timer > 0;
if (scout_stunned)
{
    scout_stop_charge_sound();
    scout_stop_roll_sound();
    if (!scout_was_stunned)
    {
        scout_stun_elapsed = 0;
        // Source audio compensates for pitch playback: +50% pitch, +30% overall speed.
        world_sfx_play(sfxScoutStunMini, x, y, 1, scout_sfx_pitch);
    }
    else scout_stun_elapsed += dt;
}
scout_was_stunned = scout_stunned;
// Parry time includes knockback and does not depend on the player's existence.
if (attack_state == 5)
{
    stun_timer = max(0, stun_timer - dt);
    if (stun_timer <= 0)
    {
        attack_state = 0;
        attack_rocking = false;
        attack_cooldown = random_range(attack_cooldown_min, attack_cooldown_max);
    }
}

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

else if (scout_parry_locked)
{
    path_end();
    is_climbing = false;
}
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

    if (player != noone || attack_state == 4)
    {
        switch (attack_state)
        {
            // =====================================
            // NORMAL CHASE AND CLOSE-RANGE ATTACK
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

                // Roll has its own reach; wind up here instead of walking
                // into the old 55-90px attack positioning band first.
                if (attack_cooldown <= 0 && scout_roll_spacing_timer <= 0 && scout_can_roll_at(player))
                {
                    path_end();
                    attack_rocking = false;
                    attack_origin_x = x;
                    attack_origin_y = y;
                    scout_charge_rate_variation = random_range(
                        scout_charge_rate_variation_min, scout_charge_rate_variation_max);
                    attack_charge_timer = scout_animation_duration(s_Scout_charge);
                    scout_stagger_group_rolls();
                    attack_state = 2;
                    repath_timer = 0;
                    scout_stop_charge_sound();
                    scout_charge_sound = world_sfx_play(sfxChargeUp, x, y, 1, scout_sfx_pitch);
                    break;
                }

                // =====================================
                // ENTER CLOSE-RANGE ATTACK
                // =====================================

                if (!attack_rocking)
                {
                    if (
                        !scout_bite_in_range(player)
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
                        attack_bite_damage_timer = attack_bite_damage_delay;
                        scout_attack_enter_complete = false;
                        image_index = 0;

                    }
                }
                else if (!scout_bite_in_range(player))
                {
                    attack_rocking = false;
                    repath_timer = 0;
                }
                // Stay planted throughout attackEnter and the looping attack.

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
                    scout_stop_charge_sound();
                    scout_charge_sound = world_sfx_play(sfxChargeUp, x, y, 1, scout_sfx_pitch);
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

                if (scout_animation_finished(s_Scout_charge))
                {
                    attack_shake_x = 0;
                    attack_shake_y = 0;

                    var _roll_dx = (player.bbox_left + player.bbox_right
                        - bbox_left - bbox_right) * 0.5;
                    // Predict once at launch, then keep the committed destination.
                    var _lead = clamp(player.phy_speed_x * game_get_speed(gamespeed_fps)
                        * scout_roll_prediction_time,
                        -scout_roll_prediction_limit, scout_roll_prediction_limit);
                    var _roll_aim = _roll_dx + _lead;
                    var dash_direction = sign(_roll_aim);
                    if (dash_direction == 0) dash_direction = scout_facing;
                    attack_side = dash_direction;
                    attack_target_x = x + clamp(_roll_aim,
                        -scout_roll_range - scout_roll_prediction_limit,
                        scout_roll_range + scout_roll_prediction_limit)
                        + dash_direction * attack_dash_overshoot;
                    attack_hit_player = false;
                    attack_state = 3;
                    scout_stop_charge_sound();
                    scout_stop_roll_sound();
                    scout_roll_sound = world_sfx_play(sfxScoutRoll, x, y, 1, scout_sfx_pitch);
                }

                break;
            }


           // =====================================
            // ROLL: STOP ON CONTACT OR A CONFIRMED MISS
            // =====================================
            case 3:
            {
                var _dash_finished = false;
                var _dash_distance = max(0, attack_dash_speed * dt);

                attack_register_dash_hit(player);

                // Sweep in <=1px increments to detect contact and walls.
                var _dash_steps = ceil(_dash_distance);

                if (_dash_steps > 0 && attack_state == 3)
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

                        if (attack_state == 4 || (attack_target_x - x) * attack_side <= 0)
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

                    attack_rocking = false;
                    scout_finish_roll();
                }

                break;
            }


        
            // =====================================
            // SLIDING STOP
            // =====================================

            case 4:
            {
                path_end();
                is_climbing = false;
                var _stop_duration = scout_animation_duration(s_Scout_chargeStop);
                var _slide_time = min(dt, max(0, _stop_duration - scout_stop_timer));
                // Integrate linear deceleration; sweep against walls and ledges.
                var _slide_speed = attack_hit_player ? attack_stop_slide_speed : attack_miss_slide_speed;
                var _slide_distance = _slide_speed * _slide_time
                    * max(0, 1 - (scout_stop_timer + _slide_time * 0.5) / _stop_duration);
                var _slide_steps = ceil(_slide_distance);
                if (_slide_steps > 0)
                {
                    var _slide_dx = attack_side * _slide_distance / _slide_steps;
                    repeat (_slide_steps)
                    {
                        if (place_meeting(x + _slide_dx, y, o_Block)
                            || !place_meeting(x + _slide_dx, y + ground_check_distance, o_Block)) break;
                        x += _slide_dx;
                    }
                }
                scout_stop_timer += dt;
                if (scout_animation_finished(s_Scout_chargeStop))
                {
                    attack_state = 0;
                    repath_timer = 0;
                    attack_cooldown = random_range(attack_cooldown_min, attack_cooldown_max);
                }
                break;
            }

            // =====================================
            // STUN AFTER PARRY
            // =====================================

            case 5:
                path_end();
                break;

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

if (is_climbing)
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

var _hit_active = scout_hit_pending
    && scout_hit_elapsed < scout_animation_duration(hit_sprite);
if (!_hit_active) scout_hit_pending = false;
hit_timer = _hit_active ? max(0, scout_animation_duration(hit_sprite) - scout_hit_elapsed) : 0;
var _sprite = s_Scout_idle;
var _stun_remaining = max(stun_timer, max(slam_stun_timer, slam_knockback_timer));
var _stun_exit_time = scout_animation_duration(s_Scout_stunExit);
var _stun_exit = false;
if (scout_stunned || _stun_remaining > 0)
{
    if (_stun_remaining <= _stun_exit_time)
    {
        _sprite = s_Scout_stunExit;
        _stun_exit = true;
    }
    else if (scout_stun_elapsed < scout_animation_duration(s_Scout_stunEnter))
        _sprite = s_Scout_stunEnter;
    else _sprite = s_Scout_stun;
}
else if (attack_state == 3) _sprite = s_Scout_roll;
else if (is_climbing) _sprite = climb_sprite;
else if (attack_state == 4) _sprite = s_Scout_chargeStop;
else if (_hit_active) _sprite = hit_sprite;
else if (attack_state == 2) _sprite = s_Scout_charge;
else if (attack_state == 0 && attack_rocking)
{
    _sprite = !scout_attack_enter_complete ? s_Scout_attackEnter : bite_sprite;
}
else if (abs(x - scout_start_x) > 0.001) _sprite = s_Scout_walk;

if (_sprite != sprite_index)
{
    sprite_index = _sprite;
    scout_animation_time = 0;
}
if (_sprite == hit_sprite) scout_animation_time = scout_hit_elapsed;
else
{
    scout_hit_pending = false;
    hit_timer = 0;
}
var _duration = scout_animation_duration(_sprite);
var _frames = sprite_get_number(_sprite);
var _one_shot = _sprite == s_Scout_charge || _sprite == s_Scout_chargeStop
    || _sprite == s_Scout_attackEnter || _sprite == s_Scout_stunEnter
    || _sprite == s_Scout_stunExit || _sprite == hit_sprite;
if (_stun_exit) scout_animation_time = max(0, _duration - _stun_remaining);
image_index = _one_shot
    ? min(_frames - 1, floor(scout_animation_time * _frames / _duration))
    : floor(scout_animation_time * _frames / _duration) mod _frames;
image_speed = 0;

// Play each bite once per animation cycle.
if (_sprite == bite_sprite && attack_state == 0 && attack_rocking)
{
    var _attack_cycle = floor(scout_animation_time / _duration);
    if (_attack_cycle != scout_attack_sound_cycle)
    {
        world_sfx_play(sfxScoutAttack, x, y, 1, scout_sfx_pitch);
        scout_attack_sound_cycle = _attack_cycle;
    }
}
else scout_attack_sound_cycle = -1;

// Random footsteps, with no sample repeated more than twice consecutively.
if (_sprite == s_Scout_walk && is_grounded && abs(x - scout_start_x) > 0.001)
{
    var _footstep = floor(scout_animation_time * 2 / _duration);
    if (_footstep != scout_footstep_index)
    {
        var _sound_count = array_length(scout_walk_sounds);
        var _sound_index = irandom(_sound_count - 1);
        if (scout_walk_sound_repeat_count >= 2)
        {
            _sound_index = irandom(_sound_count - 2);
            if (_sound_index >= scout_last_walk_sound_index) _sound_index++;
        }
        scout_walk_sound_repeat_count = _sound_index == scout_last_walk_sound_index
            ? scout_walk_sound_repeat_count + 1 : 1;
        scout_last_walk_sound_index = _sound_index;
        world_sfx_play(scout_walk_sounds[_sound_index], x, y, 1, scout_sfx_pitch);
        scout_footstep_index = _footstep;
    }
}
else scout_footstep_index = -1;

// Lock facing during the roll and stop; face the player for planted attacks.
if (attack_state == 3 || attack_state == 4) scout_facing = attack_side;
else if (!scout_stunned && is_climbing) scout_facing = climb_direction;
else if (!scout_stunned)
{
    var _face_player = instance_nearest(x, y, o_Player);
    if (_face_player != noone)
    {
        var _face_dx = (_face_player.bbox_left + _face_player.bbox_right)
            - (bbox_left + bbox_right);
        if (_face_dx != 0) scout_facing = sign(_face_dx);
    }
}

// The entry animation gives the player a harmless dodge window.
if (attack_state == 0 && attack_rocking && sprite_index == bite_sprite
    && scout_attack_enter_complete && !scout_parry_locked && !slam_locked)
{
    var bite_target = instance_place(x, y, o_Player);
    if (bite_target != noone
        && bite_target.dmg_cooldown <= 0)
    {
        if (bite_target.take_damage(attack_bite_damage, x))
            bite_target.dmg_cooldown = 1;
    }
}
