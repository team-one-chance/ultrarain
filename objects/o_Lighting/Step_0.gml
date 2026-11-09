pixelation_size = menu_pixelization_active() ? pixelation_alternate_size : 1.0;

// Keep the sprite and emitted light on the same per-instance flicker state.
var _dt = min((variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) / 1000000, 0.05);
resolution_indicator_timer = max(0, resolution_indicator_timer - _dt);

var _settings = ceiling_flicker;
with (o_light_ceil_long_ow)
{
    if (variable_instance_exists(id, "lamp_broken") && lamp_broken) continue;
    if (!variable_instance_exists(id, "light_flicker_timer"))
    {
        light_flickering = false;
        light_flicker_timer = random_range(_settings.interval_min, _settings.interval_max);
    }
    image_speed = 0;
    light_flicker_timer -= _dt;
    if (light_flicker_timer <= 0)
    {
        light_flickering = !light_flickering;
        light_flicker_timer = light_flickering
            ? random_range(_settings.duration_min, _settings.duration_max)
            : random_range(_settings.interval_min, _settings.interval_max);
    }
    // Long broken state on frame 1; short glow pulse on frame 2.
    image_index = light_flickering ? 1 : 0;
}
