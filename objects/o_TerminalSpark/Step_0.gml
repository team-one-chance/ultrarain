x += drift;
y += fall_speed;
fall_speed += 0.07;

life--;

if (life <= 0)
{
    instance_destroy();
}