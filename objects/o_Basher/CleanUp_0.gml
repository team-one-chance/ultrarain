mp_grid_destroy(nav_grid);
if (path_exists(enemy_path)) path_delete(enemy_path);
if (instance_number(o_Basher) <= 1) global.basher_tuner_capture_mouse = false;
