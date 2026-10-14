var _dt = max(0, (variable_global_exists("dev_delta_time")
    ? global.dev_delta_time : delta_time) / 1000000);
transition_cooldown = max(0, transition_cooldown - _dt);
