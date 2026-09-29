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

	var _shot_count = 1;

	var _perfect_threshold = 0.05;

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
	// APEX SHOT MULTIPLIER
	// =================================

	var _coin_y_speed =
	  abs(_current_coin.phy_speed_y);


	// PERFECT APEX
	// Extremely close to zero vertical speed.
	if (_coin_y_speed <= _perfect_threshold)
	{
		_shot_count =
		  max(_shot_count, 4);

		// Flash screen for perfect apex.
		perfect_apex_flash_timer =
		perfect_apex_flash_duration;
	}


	// NORMAL APEX WINDOW
	else if (_coin_y_speed <= _split_threshold)
	{
	 _shot_count =
		 max(_shot_count, 2);
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

// _shot_count should already be:
// 1 = normal coin
// 2 = apex
// 4 = perfect apex


// =====================================
// PREPARE SHOTS
// =====================================

var _shot_targets =
    array_create(_shot_count, noone);

var _shot_x =
    array_create(_shot_count, _last_x);

var _shot_y =
    array_create(_shot_count, _last_y);


// Try to spread shots across different enemies first.
var _used_targets =
    ds_list_create();


// =====================================
// CHOOSE EVERY TARGET BEFORE DAMAGE
// =====================================

for (
    var shot_index = 0;
    shot_index < _shot_count;
    shot_index++
)
{
    var _target = noone;
    var _target_distance = _range + 1;

    var _enemy_count =
        instance_number(oEnemyParent);


    // =================================
    // FIRST PASS:
    // FIND UNUSED ENEMY
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


        // Prefer an enemy that hasn't
        // received one of the split rays yet.
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


    // =================================
    // SECOND PASS:
    // ALL ENEMIES ALREADY USED
    // =================================

    // Not enough enemies for every ray.
    // Reuse the nearest enemy.
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


    // No enemies at all.
    if (_target == noone)
    {
        continue;
    }


    // Remember that this enemy received a ray.
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


    // =================================
    // DIFFERENT VISUAL HIT POSITION
    // =================================

    // Spread rays across different parts
    // of the enemy's collision box.

    var _fraction_x =
        (shot_index + 1)
        / (_shot_count + 1);

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


// =====================================
// FIRE ALL PREPARED SHOTS
// =====================================

for (
    var shot_index = 0;
    shot_index < _shot_count;
    shot_index++
)
{
    var _target =
        _shot_targets[shot_index];


    if (_target == noone)
    {
        continue;
    }


    // =================================
    // VISUAL
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
        _shot_x[shot_index];

    _final_visual.line_y2 =
        _shot_y[shot_index];


    // =================================
    // DAMAGE
    // =================================

    // Target may have died from a previous
    // ray, but the remaining visuals still fire.
    if (instance_exists(_target))
    {
        _target.take_damage(
            _current_damage
        );
    }
}


ds_list_destroy(
    _used_targets
);
}