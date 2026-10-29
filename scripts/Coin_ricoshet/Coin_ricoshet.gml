// Send a blocked bullet back out at a random angle using the coin target trace.
function breaker_bullet_ricochet(_breaker, _hit_x, _hit_y, _damage)
{
    if (!instance_exists(_breaker)) return;
    var _settings = breaker_slam_visual_settings().shield_bullet_ricochet;
    var _side = _breaker.facing_direction; // Horizontal side from which the shield faces, -1 or +1.
    var _start_x = _side > 0 ? _breaker.bbox_right + 2 : _breaker.bbox_left - 2;
    var _start_y = clamp(_hit_y, _breaker.bbox_top + 2, _breaker.bbox_bottom - 2);
    var _out_direction = (_side > 0 ? 0 : 180)
        + random_range(-_settings.random_spread_degrees, _settings.random_spread_degrees);
    var _end_x = _start_x + lengthdir_x(_settings.range_pixels, _out_direction);
    var _end_y = _start_y + lengthdir_y(_settings.range_pixels, _out_direction);
    var _chain = { walls_left: 0, enemies_left: 0 }; // Stop at the first target or wall.
    var _hit_enemies = ds_list_create();
    var _trace = coin_chain_trace(_start_x, _start_y, _end_x, _end_y,
        _damage * _settings.damage_fraction, _chain, _hit_enemies, false);
    ds_list_destroy(_hit_enemies);
    var _visual = instance_create_layer(0, 0, "Instances", o_HitscanVisual);
    _visual.line_x1 = _hit_x;
    _visual.line_y1 = _hit_y;
    _visual.line_x2 = _trace.end_x;
    _visual.line_y2 = _trace.end_y;
    _visual.line_color = c_yellow;
    _visual.line_width = 1.2;
    _visual.set_coin_effects(1, false);
    _visual.bounce_travel = true;
    _visual.bounce_origin_x = _hit_x;
    _visual.bounce_origin_y = _hit_y;
    _visual.bounce_target_x = _trace.end_x;
    _visual.bounce_target_y = _trace.end_y;
    _visual.bounce_speed = _settings.trail_speed_pixels_per_second; // Room pixels per second.
    _visual.bounce_tail_length = _settings.trail_length_pixels; // Room pixels of visible streak.
    var _ricochet_sounds = [sfxBreakerBulletRicochet1, sfxBreakerBulletRicochet2, sfxBreakerBulletRicochet3];
    _breaker.breaker_play_hit_sound(_ricochet_sounds[irandom(2)]); // Choose one of the three shield ricochet cues per impact.
}

function coin_ricochet(
    _coin,
    _damage,
    _range,
    _split_threshold = 0.75
)
{
    if (!instance_exists(_coin))
    {
        return;
    }


    // =====================================
    // COLLECT ALL CURRENT COINS
    // =====================================

    var _coins =
        ds_list_create();

    var _coin_count =
        instance_number(o_Coin);

    for (var i = 0; i < _coin_count; i++)
    {
        var _found_coin =
            instance_find(
                o_Coin,
                i
            );

        if (instance_exists(_found_coin))
        {
            ds_list_add(
                _coins,
                _found_coin
            );
        }
    }


    // =====================================
    // CHAIN STATE
    // =====================================

    // One penetration per shot path. Split branches copy the remaining budget.
    // The optional future item grants one enemy penetration per shot path.
    var _enemy_piercing = variable_instance_exists(id, "item_coin_enemy_piercing")
        && variable_instance_get(id, "item_coin_enemy_piercing");
    var _chain = { walls_left: 1, enemies_left: _enemy_piercing ? 1 : 0 };
	// Shared by every coin and every split shot in this chain.
var _chain_hit_enemies = ds_list_create();

    var _current_coin =
        _coin;

    var _current_damage =
        _damage;

    var _perfect_threshold =
        0.1;

    var _chain_perfect_apex = false;
    var _ricochet_color = c_yellow;
    var _ricochet_width = 1;
    var _coin_bounces = 0;
    var _shot_visuals = [];
	
	var _rounding_level = item_get_level(id, "coin_rounding");
	
	show_debug_message(
    "COIN ITEM CHECK"
    + " | player=" + string(id)
    + " | rounding level=" + string(_rounding_level)
);


    // =====================================
    // TRAVEL THROUGH EVERY COIN
    // =====================================

    while (instance_exists(_current_coin))
    {
        // Apply the coin's boost to every outgoing shot, using the incoming style.
        _ricochet_color = merge_color(_ricochet_color, c_red, 0.2);
        _ricochet_width *= 1.2;
        _coin_bounces++;

        var _last_x =
            _current_coin.x;

        var _last_y =
            _current_coin.y;


        // =================================
        // THIS COIN'S SHOT COUNT
        // =================================

        var _coin_shot_count = 1;

        var _coin_y_speed =
            abs(_current_coin.phy_speed_y);


        // PERFECT APEX
        if (_coin_y_speed <= _perfect_threshold)
        {
            _coin_shot_count = 4;
            _chain_perfect_apex = true;
			_current_damage += 7

            perfect_apex_flash_timer =
                perfect_apex_flash_duration;
        }

        // NORMAL APEX
        else if (_coin_y_speed <= _split_threshold)
        {
            _coin_shot_count = 2;
			_current_damage += 5
        }


        // =================================
        // EVERY COIN MULTIPLIES DAMAGE BY 1.65
        // =================================

var _damage_before_multiplier = _current_damage;
var _damage_before_rounding = _damage_before_multiplier * 1.45;

_current_damage = coin_round_damage(
    _damage_before_rounding,
    _rounding_level
);

show_debug_message(
    "COIN ROUNDING"
    + " | level=" + string(_rounding_level)
    + " | incoming=" + string(_damage_before_multiplier)
    + " | multiplied=" + string(_damage_before_rounding)
    + " | rounded=" + string(_current_damage)
);


        // =================================
        // REMOVE CURRENT COIN FROM LIST
        // =================================

        var _current_index =
            ds_list_find_index(
                _coins,
                _current_coin
            );

        if (_current_index != -1)
        {
            ds_list_delete(
                _coins,
                _current_index
            );
        }


        // =================================
        // FIND NEAREST UNUSED COIN
        // =================================

        var _next_coin =
            noone;

        var _next_distance =
            _range + 1;


        for (
            var i = 0;
            i < ds_list_size(_coins);
            i++
        )
        {
            var _candidate =
                _coins[| i];

            if (!instance_exists(_candidate))
            {
                continue;
            }


            var _distance =
                point_distance(
                    _last_x,
                    _last_y,
                    _candidate.x,
                    _candidate.y
                );


            if (
                _distance < _next_distance
                && _distance <= _range
            )
            {
                _next_distance =
                    _distance;

                _next_coin =
                    _candidate;
            }
        }


        // =================================
        // DECIDE HOW MANY SHOTS HIT ENEMIES
        // =================================

        var _enemy_shot_count =
            _coin_shot_count;


        // One shot is reserved for continuing
        // the chain into the next coin.
        if (_next_coin != noone)
        {
            _enemy_shot_count -= 1;
        }


        // =====================================
        // FIRE THIS COIN'S ENEMY SHOTS
        // =====================================

        if (_enemy_shot_count > 0)
        {
            var _shot_targets =
                array_create(
                    _enemy_shot_count,
                    noone
                );

            var _shot_x =
                array_create(
                    _enemy_shot_count,
                    _last_x
                );

            var _shot_y =
                array_create(
                    _enemy_shot_count,
                    _last_y
                );


            var _used_targets =
                ds_list_create();


            // =================================
            // CHOOSE ALL TARGETS FIRST
            // =================================

            for (
                var shot_index = 0;
                shot_index < _enemy_shot_count;
                shot_index++
            )
            {
                var _target =
                    noone;

                var _target_distance =
                    _range + 1;

                var _enemy_count =
                    instance_number(
                        oEnemyParent
                    );


                // =============================
                // FIRST PASS:
                // UNUSED ENEMIES
                // =============================

                for (
                    var i = 0;
                    i < _enemy_count;
                    i++
                )
                {
                    var _enemy =
                        instance_find(
                            oEnemyParent,
                            i
                        );

                    if (!instance_exists(_enemy))
                    {
                        continue;
                    }


                    if (
                        ds_list_find_index(
                            _used_targets,
                            _enemy
                        )
                        != -1
                    )
                    {
                        continue;
                    }
// First, prefer enemies that haven't been hit by this chain.
if (ds_list_find_index(_chain_hit_enemies, _enemy) != -1)
{
    continue;
}

                    var _distance =
                        point_distance(
                            _last_x,
                            _last_y,
                            _enemy.x,
                            _enemy.y
                        );


                    if (
                        _distance < _target_distance
                        && _distance <= _range
                    )
                    {
                        _target_distance =
                            _distance;

                        _target =
                            _enemy;
                    }
                }


                // =============================
                // SECOND PASS:
                // REUSE NEAREST ENEMY
                // =============================

if (_target == noone)
{
    // First try an enemy that another shot from this coin
    // hasn't selected. If none remain, allow any enemy.
    for (var _pass = 0; _pass < 2; _pass++)
    {
        _target_distance = _range + 1;

        for (var _i = 0; _i < _enemy_count; _i++)
        {
            var _enemy = instance_find(oEnemyParent, _i);

            if (!instance_exists(_enemy))
                continue;

            if (_pass == 0
            && ds_list_find_index(_used_targets, _enemy) != -1)
            {
                continue;
            }

            var _distance = point_distance(
                _last_x,
                _last_y,
                _enemy.x,
                _enemy.y
            );

            if (_distance < _target_distance && _distance <= _range)
            {
                _target_distance = _distance;
                _target = _enemy;
            }
        }

        if (_target != noone)
            break;
    }
}


                if (_target == noone)
                {
                    continue;
                }


                if (
                    ds_list_find_index(
                        _used_targets,
                        _target
                    )
                    == -1
                )
                {
                    ds_list_add(
                        _used_targets,
                        _target
                    );
                }


                // =============================
                // DIFFERENT VISUAL HIT POINTS
                // =============================

                var _fraction_x =
                    (shot_index + 1)
                    / (_enemy_shot_count + 1);

                var _fraction_y;

                if ((shot_index mod 2) == 0)
                {
                    _fraction_y = 0.35;
                }
                else
                {
                    _fraction_y = 0.65;
                }


                _shot_targets[shot_index] =
                    _target;

                _shot_x[shot_index] =
                    lerp(
                        _target.bbox_left,
                        _target.bbox_right,
                        _fraction_x
                    );

                _shot_y[shot_index] =
                    lerp(
                        _target.bbox_top,
                        _target.bbox_bottom,
                        _fraction_y
                    );
            }


            // =================================
            // FIRE PREPARED ENEMY SHOTS
            // =================================

            for (
                var shot_index = 0;
                shot_index < _enemy_shot_count;
                shot_index++
            )
            {
                var _target =
                    _shot_targets[shot_index];

                if (_target == noone)
                {
                    continue;
                }


                // This branch spends its own budget, without changing siblings.
                var _branch = {
                    walls_left: _chain.walls_left,
                    enemies_left: _chain.enemies_left
                };

                var _end_x = _shot_x[shot_index];
                var _end_y = _shot_y[shot_index];

                // With the item, continue beyond the selected enemy along the ray.
                if (_branch.enemies_left > 0)
                {
                    var _direction = point_direction(
                        _last_x, _last_y, _end_x, _end_y
                    );
                    _end_x = _last_x + lengthdir_x(_range, _direction);
                    _end_y = _last_y + lengthdir_y(_range, _direction);
                }

                var _trace = coin_chain_trace(
                    _last_x, _last_y,
                    _end_x, _end_y,
                    _current_damage, _branch, _chain_hit_enemies
                );

                var _enemy_visual = instance_create_layer(
                    0, 0, "Instances", o_HitscanVisual
                );
                _enemy_visual.line_x1 = _last_x;
                _enemy_visual.line_y1 = _last_y;
                _enemy_visual.line_x2 = _trace.end_x;
                _enemy_visual.line_y2 = _trace.end_y;
                array_push(_shot_visuals, _enemy_visual);

            }


            ds_list_destroy(
                _used_targets
            );
        }


        // =====================================
        // CONTINUE INTO NEXT COIN
        // =====================================

        if (_next_coin != noone)
        {
            if (instance_exists(_next_coin))
            {
var _chain_trace = coin_chain_trace(
    _last_x, _last_y, _next_coin.x, _next_coin.y,
    _current_damage, _chain, _chain_hit_enemies
);

                var _chain_visual = instance_create_layer(
                    0, 0, "Instances", o_HitscanVisual
                );
                _chain_visual.line_x1 = _last_x;
                _chain_visual.line_y1 = _last_y;
                _chain_visual.line_x2 = _chain_trace.end_x;
                _chain_visual.line_y2 = _chain_trace.end_y;
                array_push(_shot_visuals, _chain_visual);

                // A blocked link cannot activate the coin behind the obstacle.
                if (!_chain_trace.reached) _next_coin = noone;
            }
            else
            {
                _next_coin = noone;
            }
        }


        // Current coin has now been consumed.
        instance_destroy(
            _current_coin
        );


        // =====================================
        // END OR CONTINUE CHAIN
        // =====================================

        if (_next_coin == noone)
        {
            _current_coin =
                noone;

            break;
        }


        _current_coin =
            _next_coin;
    }


ds_list_destroy(
    _coins
);

ds_list_destroy(_chain_hit_enemies);
	

    // The whole hitscan resolves before drawing. Use the actual completed chain
    // for every segment, including early links and split shots.
    for (var _visual_index = 0; _visual_index < array_length(_shot_visuals); _visual_index++)
    {
        var _visual = _shot_visuals[_visual_index];
        if (!instance_exists(_visual)) continue;
        _visual.line_color = _ricochet_color;
        _visual.line_width = _ricochet_width;
        _visual.set_coin_effects(_coin_bounces, _chain_perfect_apex);
    }

    // One cue for the entire shot, regardless of how many coins it chained.
    audio_play_sound(_chain_perfect_apex ? sfxBulletFlash : sfxRicochet, 1, false);
    return { color: _ricochet_color, width: _ricochet_width,
        bounces: _coin_bounces, bullet_flash: _chain_perfect_apex };
}


// The continuation carries its budget; each split branch receives its own copy.
// Repeated pixels inside one wall consume only one hit per ray.
function coin_chain_trace(
    _sx, _sy, _ex, _ey,
    _damage, _chain, _chain_hit_enemies, _allow_shield_bounce = true
)
{
    var _seen = ds_list_create();
    var _hits = ds_list_create();
    var _steps = max(1, ceil(point_distance(_sx, _sy, _ex, _ey)));
    var _end_x = _ex;
    var _end_y = _ey;
    var _stopped = false;

    for (var _step = 0; _step <= _steps; _step++)
    {
        var _fraction = _step / _steps;
        var _px = lerp(_sx, _ex, _fraction);
        var _py = lerp(_sy, _ey, _fraction);
        ds_list_clear(_hits);

        collision_point_list(
            _px, _py,
            [o_Block, o_Door_UNB, o_Door_Breakable,
                o_Chute_Breakable, oEnemyParent],
            false, true, _hits, false
        );

        for (var _i = 0; _i < ds_list_size(_hits); _i++)
        {
            var _hit = _hits[| _i];
            if (!instance_exists(_hit)) continue;
            if (ds_list_find_index(_seen, _hit) != -1) continue;

            var _object = _hit.object_index;
            var _enemy = _object == oEnemyParent
                || object_is_ancestor(_object, oEnemyParent);
            var _big_door = _object == o_Door_UNB
                || object_is_ancestor(_object, o_Door_UNB);
            var _damageable_door = variable_instance_exists(_hit, "door_take_damage");

            // Fully open doors and already broken panels do not block the ray.
            if (_big_door && _hit.door_state == 2) continue;
            if (_damageable_door && (_hit.broken || _hit.break_requested)) continue;

            ds_list_add(_seen, _hit);

            weapon_bullet_impact(_hit, _px, _py,
                point_direction(_sx, _sy, _ex, _ey), _enemy);

if (_enemy)
{
    var _repeat_hit =
        ds_list_find_index(_chain_hit_enemies, _hit) != -1;

    var _hit_damage = _repeat_hit ? _damage * 0.25 : _damage;

    if (!_repeat_hit)
        ds_list_add(_chain_hit_enemies, _hit);

    show_debug_message(
        "COIN ENEMY HIT"
        + " | repeat=" + string(_repeat_hit)
        + " | damage=" + string(_hit_damage)
    );

    var _shield_bounce = _allow_shield_bounce
        && variable_instance_exists(_hit, "breaker_hit_from_back")
        && _hit.shield_hp > 0 && !_hit.is_invulnerable()
        && !_hit.breaker_hit_from_back();
    _hit.take_damage(_hit_damage);
    if (_shield_bounce)
    {
        breaker_bullet_ricochet(_hit, _px, _py, _hit_damage);
        _stopped = true; // The shield blocks the incoming coin segment.
    }
                if (_chain.enemies_left > 0)
                    _chain.enemies_left--;
                else
                    _stopped = true;
            }
            else
            {
                if (_object == o_Block_Breakable)
                    _hit.take_damage(_damage);
                else if (_damageable_door)
                    _hit.door_take_damage(_damage);

                // Large closed doors stay bulletproof.
                if (_big_door)
                {
                    _stopped = true;
                }
                else if (_chain.walls_left > 0)
                {
                    _chain.walls_left--;
                }
                else
                {
                    _stopped = true;
                }
            }

            if (_stopped)
            {
                _end_x = _px;
                _end_y = _py;
                break;
            }
        }

        if (_stopped) break;
    }

    ds_list_destroy(_hits);
    ds_list_destroy(_seen);
    return { end_x: _end_x, end_y: _end_y, reached: !_stopped };
}
