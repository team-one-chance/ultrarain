var _dt = min((variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) / 1000000, 0.05);
flash_life = max(0, flash_life - _dt);
for (var _i = array_length(particles) - 1; _i >= 0; _i--)
{
    var _p = particles[_i];
    _p.life -= _dt;
    if (_p.life <= 0)
    {
        array_delete(particles, _i, 1);
        continue;
    }
    _p.px += _p.vx * _dt;
    _p.py += _p.vy * _dt;
    if (!_p.dust) _p.vy += spark_gravity * _dt;
}
if (array_length(particles) == 0) instance_destroy();
