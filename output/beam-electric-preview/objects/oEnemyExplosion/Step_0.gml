var _dt = max(0, (variable_global_exists("dev_delta_time")
    ? global.dev_delta_time : delta_time) / 1000000);
fx_age += _dt;
if (fx_age >= fx_duration)
{
    instance_destroy();
    exit;
}
for (var _i = array_length(fx_particles) - 1; _i >= 0; _i--)
{
    var _p = fx_particles[_i];
    _p.life -= _dt;
    if (_p.life <= 0)
    {
        array_delete(fx_particles, _i, 1);
        continue;
    }
    _p.px += _p.vx * _dt;
    _p.py += _p.vy * _dt;
    _p.vy += fx_gravity * _dt;
    _p.angle += _p.spin * _dt;
}
