// =====================================
// LIFETIME
// =====================================

life -= delta_time / 1000000;

if (life <= 0)
{
    instance_destroy();
    exit;
}


// =====================================
// CALCULATE MOVEMENT
// =====================================

var move_x = lengthdir_x(move_speed, move_dir);
var move_y = lengthdir_y(move_speed, move_dir);

var old_left   = bbox_left;
var old_top    = bbox_top;
var old_right  = bbox_right;
var old_bottom = bbox_bottom;

// Entire area crossed this frame
var sweep_left   = min(old_left,   old_left   + move_x);
var sweep_top    = min(old_top,    old_top    + move_y);
var sweep_right  = max(old_right,  old_right  + move_x);
var sweep_bottom = max(old_bottom, old_bottom + move_y);


// =====================================
// STOP AT WALLS
// =====================================

if (collision_rectangle(
    sweep_left,
    sweep_top,
    sweep_right,
    sweep_bottom,
    o_Block,
    false,
    true
) != noone)
{
    instance_destroy();
    exit;
}


// Move beam
x += move_x;
y += move_y;


// =====================================
// FIND ENEMIES CROSSED THIS FRAME
// =====================================

var hits = ds_list_create();

collision_rectangle_list(
    sweep_left,
    sweep_top,
    sweep_right,
    sweep_bottom,
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

    if (
        instance_exists(enemy)
        && ds_list_find_index(hit_enemies, enemy) == -1
    )
    {
        ds_list_add(hit_enemies, enemy);

        enemy.take_damage(
            beam_damage,
            move_dir,
            knockback_force
        );
    }
}

ds_list_destroy(hits);