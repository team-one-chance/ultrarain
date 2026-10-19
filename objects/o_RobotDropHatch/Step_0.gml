var _dt = (variable_global_exists("dev_delta_time")
    ? global.dev_delta_time : delta_time) / 1000000;
if (!instance_exists(drop_emitter)) {
    instance_destroy();
    exit;
}
hatch_age += _dt;
hatch_stage_time += _dt;
if (hatch_age > 2) {
    instance_destroy();
    exit;
}
switch (hatch_stage) {
    case 0:
        if (!hatch_open_sound_played)
        {
            hatch_open_sound_played = true;
            world_sfx_play(sfxDropperHatchOpen, x, hatch_lip_y, 0.65, 1, 480);
        }
        // Appear and quickly slide the two shutters into the frame.
        hatch_alpha = clamp(hatch_age / 0.04, 0, 1);
        hatch_open = clamp(hatch_stage_time / hatch_open_duration, 0, 1);
        if (hatch_open >= 1) {
            drop_body = drop_emitter.release_robot(x, hatch_lip_y);
            hatch_stage = 1;
            hatch_stage_time = 0;
        }
        break;
    case 1:
        // Close as soon as the whole robot has cleared the mouth.
        var _clear = !instance_exists(drop_body);
        if (!_clear) _clear = drop_body.y - 24 * drop_body.scrap_size >= hatch_lip_y + 2;
        if (_clear || hatch_stage_time >= 0.5) {
            hatch_stage = 2;
            hatch_stage_time = 0;
        }
        break;
    case 2:
        hatch_open = 1 - clamp(hatch_stage_time / hatch_close_duration, 0, 1);
        if (hatch_open <= 0) {
            hatch_stage = 3;
            hatch_stage_time = 0;
        }
        break;
    case 3:
        hatch_alpha = 1 - clamp(hatch_stage_time / hatch_fade_duration, 0, 1);
        if (hatch_alpha <= 0) instance_destroy();
        break;
}
