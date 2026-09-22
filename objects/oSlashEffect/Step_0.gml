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
    25,
    knockback_dir,
    30
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