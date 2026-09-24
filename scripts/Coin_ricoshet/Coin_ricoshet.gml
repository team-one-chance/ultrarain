function coin_ricochet(_coin, _damage, _range)
{
    if (!instance_exists(_coin))
    {
        return;
    }


    // =====================================
    // FIND NEAREST ENEMY
    // =====================================

    var target =
        instance_nearest(
            _coin.x,
            _coin.y,
            oEnemy_TEMP
        );


    // No enemy exists
    if (target == noone)
    {
        instance_destroy(_coin);
        return;
    }


    // Enemy too far away
    var target_distance =
        point_distance(
            _coin.x,
            _coin.y,
            target.x,
            target.y
        );

    if (target_distance > _range)
    {
        instance_destroy(_coin);
        return;
    }


    // =====================================
    // DAMAGE TARGET
    // =====================================

    target.ehp -= _damage;
    target.hit_timer = 0.15;


    show_debug_message(
        "COIN RICOCHET! Damage: "
        + string(_damage)
        + " | Enemy HP: "
        + string(target.ehp)
    );


    // =====================================
    // CREATE RICOCHET VISUAL
    // =====================================

    var shot = instance_create_layer(
        0,
        0,
        "Instances",
        o_HitscanVisual
    );

    shot.line_x1 = _coin.x;
    shot.line_y1 = _coin.y;

    shot.line_x2 = target.x;
    shot.line_y2 = target.y;


    // =====================================
    // KILL ENEMY
    // =====================================

    if (target.ehp <= 0)
    {
        instance_destroy(target);
    }


    // Coin is consumed after being shot
    instance_destroy(_coin);
}