var _seconds_elapsed = max(0, (variable_global_exists("dev_delta_time")
    ? global.dev_delta_time : delta_time) / 1000000); // Seconds; respects developer pause and time scaling.
effect_age_seconds += _seconds_elapsed;
if (effect_age_seconds >= max(0.001, visual_settings.duration_seconds)) instance_destroy();
