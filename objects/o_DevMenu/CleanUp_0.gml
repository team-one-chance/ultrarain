// Release only instances suspended by this controller.
thaw_world();
global.dev_freeze_enemies = false;
update_enemy_freeze();
global.dev_resume_input = false;

game_set_speed(base_game_speed, gamespeed_fps);
