var _dt = max(0, (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) / 1000000);
age += _dt;
hit_flash = max(0, hit_flash - _dt);
if (training_kind == 1) y = base_y + sin(age * 2.5) * 64; // Pixels; vertical aim-tracking amplitude.
if (training_kind == 4 && training_active() && o_TrainingSimulation.section == 0)
{
    if (point_distance(mouse_x, mouse_y, x + 12, y + 12) < 28)
    {
        audio_play_sound(sfxBalloonPop, 2, false, 0.65, 0, 1 + 0.06 * sin(x * 0.13 + y * 0.07)); // Slight pitch variation per balloon.
        ehp = 0;
        instance_destroy();
    }
}

if (training_kind == 5)
{
    if (!instance_exists(shield_owner)) { instance_destroy(); exit; }
    if (instance_exists(o_Player))
    {
        var _side = sign(o_Player.x - shield_owner.x);
        x = shield_owner.x + 16 + _side * 42 - 4;
        y = shield_owner.y - 8;
    }
}
