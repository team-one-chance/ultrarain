// =====================================
// HP
// =====================================
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






ehp_max = 100;
ehp = ehp_max;


// =====================================
// HIT EFFECT
// =====================================

hit_timer = 0;

normal_sprite = sprite_index;
hit_sprite = sEnemy_hit;
shoot_timer = 0;
shoot_cooldown = 1.5;
