// Release only instances suspended by this controller.
thaw_world();
if (surface_exists(map_cache_surface)) surface_free(map_cache_surface);
if (map_cache_camera != -1) camera_destroy(map_cache_camera);
global.dev_freeze_enemies = false;
update_enemy_freeze();
global.dev_resume_input = false;

game_set_speed(base_game_speed, gamespeed_fps);
