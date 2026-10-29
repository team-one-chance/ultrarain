// Every enemy owns the navigation resources allocated by the parent Create.
path_end();
if (path_exists(enemy_path)) path_delete(enemy_path);
mp_grid_destroy(nav_grid);
