var _dt = (variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000;

x += debris_vx * _dt;
y += debris_vy * _dt;

debris_vy += 450 * _dt;
debris_life -= _dt;

if (debris_life <= 0)
{
    instance_destroy();
}