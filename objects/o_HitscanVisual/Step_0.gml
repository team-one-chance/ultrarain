life -= delta_time / 1000000;

if (life <= 0)
{
    instance_destroy();
}