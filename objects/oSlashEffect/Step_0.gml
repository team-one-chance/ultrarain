// =====================================
// DURATION
// =====================================

duration -= delta_time / 1000000;


// =====================================
// FIND ENEMIES TOUCHING SLASH
// =====================================

var hits = ds_list_create();

collision_rectangle_list(
    bbox_left,
    bbox_top,
    bbox_right,
    bbox_bottom,
    oEnemyParent,
    false,
    true,
    hits,
    false
);


// =====================================
// DAMAGE ENEMIES
// =====================================

for (var i = 0; i < ds_list_size(hits); i++)
{
    var enemy = hits[| i];

    // Don't hit the same enemy multiple times
    // during one slash
    if (ds_list_find_index(hit_enemies, enemy) == -1)
    {
        ds_list_add(hit_enemies, enemy);

       var knockback_dir;

if (image_xscale > 0)
{
    knockback_dir = 0;
}
else
{
    knockback_dir = 180;
}

enemy.take_damage(
    slash_damage,
    knockback_dir,
    knockback_force,
	true
);
    }
}

ds_list_destroy(hits);


// =====================================
// DESTROY SLASH
// =====================================

if (duration <= 0)
{
    instance_destroy();
}


// =====================================
// HIT COINS
// =====================================

var coins = ds_list_create();

collision_rectangle_list(
    bbox_left,
    bbox_top,
    bbox_right,
    bbox_bottom,
    o_Coin,
    false,
    true,
    coins,
    false
);

for (var c = 0; c < ds_list_size(coins); c++)
{
    var coin = coins[| c];

    if (instance_exists(coin))
    {
        var beam_dir;

        if (image_xscale > 0)
        {
            beam_dir = 0;
        }
        else
        {
            beam_dir = 180;
        }

        var beam = instance_create_layer(
    coin.x,
    y,
    "Instances",
    oSwordBeam
);

        beam.move_dir = beam_dir;
        beam.image_xscale = sign(image_xscale);

        // Copy this slash's damage and knockback
       beam.move_dir = beam_dir;
beam.image_xscale = sign(image_xscale);

        instance_destroy(coin);
    }
}

ds_list_destroy(coins);