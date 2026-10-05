var _dt = delta_time / 1000000;

x += debris_vx * _dt;
y += debris_vy * _dt;

debris_vy += 450 * _dt;
debris_life -= _dt;

if (debris_life <= 0)
{
    instance_destroy();
}