age += max(0, (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) / 1000000);
if (age >= lifetime) instance_destroy();
