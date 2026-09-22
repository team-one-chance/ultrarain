
var cell_size = 16;

nav_grid = mp_grid_create(
    0,
    0,
    ceil(room_width / cell_size),
    ceil(room_height / cell_size),
    cell_size,
    cell_size
);

enemy_path = path_add();
repath_timer = 0;
// =====================================
// HP
// =====================================

ehp_max = 100;
ehp = ehp_max;


// =====================================
// HIT EFFECT
// =====================================

hit_timer = 0;

normal_sprite = sprite_index;
hit_sprite = sEnemy_hit;


// =====================================
// KNOCKBACK
// =====================================

knockback_timer = 0;
knockback_x = 0;
knockback_y = 0;


// =====================================
// DAMAGE FUNCTION
// =====================================

take_damage = function(_damage, _knockback_dir = 0, _knockback_force = 0)
{
    // DAMAGE HAPPENS IMMEDIATELY
    ehp -= _damage;

    show_debug_message(
        "Enemy damaged: " + string(_damage)
        + " | HP: " + string(ehp)
    );

    // Hit indicator
    hit_timer = 0.15;


    // Knockback
    if (_knockback_force > 0)
    {
        path_end();

        knockback_timer = 0.2;

        knockback_x = lengthdir_x(
            _knockback_force,
            _knockback_dir
        );

        knockback_y = lengthdir_y(
            _knockback_force,
            _knockback_dir
        );
    }


    // Death
    if (ehp <= 0)
    {
        instance_destroy();
    }
};