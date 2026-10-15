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

    var _current_coin =
        _coin;

    var _current_damage =
        _damage;

    var _perfect_threshold =
        0.05;

    var _chain_perfect_apex = false;


    // =====================================
    // TRAVEL THROUGH EVERY COIN
    // =====================================

    while (instance_exists(_current_coin))
    {
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

            perfect_apex_flash_timer =
                perfect_apex_flash_duration;
        }

        // NORMAL APEX
        else if (_coin_y_speed <= _split_threshold)
        {
            _coin_shot_count = 2;
        }


        // =================================
        // EVERY COIN DOUBLES DAMAGE
        // =================================

        _current_damage *= (1.65);


        show_debug_message(
            "COIN CHAIN | damage="
            + string(_current_damage)
            + " | shots="
            + string(_coin_shot_count)
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
                    _target_distance =
                        _range + 1;


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


                var _enemy_visual =
                    instance_create_layer(
                        0,
                        0,
                        "Instances",
                        o_HitscanVisual
                    );

                _enemy_visual.line_x1 =
                    _last_x;

                _enemy_visual.line_y1 =
                    _last_y;

                _enemy_visual.line_x2 =
                    _shot_x[shot_index];

                _enemy_visual.line_y2 =
                    _shot_y[shot_index];


                // Target may already have died from
                // one of the other split shots.
                if (instance_exists(_target))
                {
                    instance_create_depth(
                        _shot_x[shot_index], _shot_y[shot_index],
                        -10000, o_ShotImpact,
                        {
                            impact_direction: point_direction(
                                _last_x, _last_y, _shot_x[shot_index], _shot_y[shot_index]
                            ),
                            impact_enemy: true
                        }
                    );
                    _target.take_damage(
                        _current_damage
                    );
                }
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
            var _next_x =
                _next_coin.x;

            var _next_y =
                _next_coin.y;


            var _chain_visual =
                instance_create_layer(
                    0,
                    0,
                    "Instances",
                    o_HitscanVisual
                );

            _chain_visual.line_x1 =
                _last_x;

            _chain_visual.line_y1 =
                _last_y;

            _chain_visual.line_x2 =
                _next_x;

            _chain_visual.line_y2 =
                _next_y;
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

    // One cue for the entire shot, regardless of how many coins it chained.
    audio_play_sound(_chain_perfect_apex ? sfxBulletFlash : sfxRicochet, 1, false);
}
