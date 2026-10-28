var _dt = (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) / 1000000;
life -= _dt;

if (life <= 0)
{
    instance_destroy();
}
