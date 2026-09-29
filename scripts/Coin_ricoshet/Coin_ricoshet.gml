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

    var _splitshot =
        false;

    var _last_x =
        _coin.x;

    var _last_y =
        _coin.y;


    // =====================================
    // TRAVEL THROUGH EVERY COIN
    // =====================================

    while (instance_exists(_current_coin))
    {
        // Remember this coin's position.
        _last_x =
            _current_coin.x;

        _last_y =
            _current_coin.y;


        // =================================
        // PERFECT-TIMING SPLITSHOT
        // =================================

        if (
            abs(_current_coin.phy_speed_y)
            <= _split_threshold
        )
        {
            _splitshot = true;
        }


        // =================================
        // EVERY COIN DOUBLES DAMAGE
        // =================================

        _current_damage *= 2;


        show_debug_message(
            "COIN CHAIN | damage="
            + string(_current_damage)
        );


        // Remove current coin from available list.
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


        // Current coin has been consumed.
        instance_destroy(
            _current_coin
        );


        // =================================
        // NO MORE COINS
        // =================================

        if (_next_coin == noone)
        {
            _current_coin =
                noone;

            break;
        }


        // =================================
        // DRAW COIN -> COIN SHOT
        // =================================

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
            _next_coin.x;

        _chain_visual.line_y2 =
            _next_coin.y;


        // Continue through next coin.
        _current_coin =
            _next_coin;
    }


    ds_list_destroy(
        _coins
    );


    // =====================================
    // FINAL ENEMY SHOTS
    // =====================================

    var _shot_count =
        1;

    if (_splitshot)
    {
        _shot_count = 2;
    }


    // Prevent both split shots from
    // selecting the same enemy.
    var _used_targets =
        ds_list_create();


    for (
        var shot_index = 0;
        shot_index < _shot_count;
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


        // =================================
        // FIND NEAREST UNUSED ENEMY
        // =================================

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


        // No more valid enemies.
        if (_target == noone)
        {
            break;
        }


        ds_list_add(
            _used_targets,
            _target
        );


// =================================
// SAVE TARGET POSITION FIRST
// =================================

var _target_x = _target.x;
var _target_y = _target.y;


// =================================
// DRAW FINAL RICOCHET
// =================================

var _final_visual =
    instance_create_layer(
        0,
        0,
        "Instances",
        o_HitscanVisual
    );

_final_visual.line_x1 =
    _last_x;

_final_visual.line_y1 =
    _last_y;

_final_visual.line_x2 =
    _target_x;

_final_visual.line_y2 =
    _target_y;


// =================================
// DAMAGE ENEMY LAST
// =================================

_target.take_damage(
    _current_damage
);
	}
}