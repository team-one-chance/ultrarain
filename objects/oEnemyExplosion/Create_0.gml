// Enemy death tuning: compact orange fireball and short-lived metal chips.
if (!variable_instance_exists(id, "fx_miniboss")) fx_miniboss = false;
if (!variable_instance_exists(id, "fx_scout_size")) fx_scout_size = 0;
fx_duration = 0.42;
fx_flash_duration = 0.09;
fx_flash_radius = 12;
fx_burst_duration = 0.22;
fx_burst_radius = 26;
fx_spark_count = 14;
fx_debris_count = 6;
fx_gravity = 260;
fx_colour = make_color_rgb(255, 220, 90);
fx_fire_colour = make_color_rgb(255, 100, 20);
fx_core_colour = make_color_rgb(255, 240, 170);
fx_launch_scale = 1;
fx_debris_scale = 1;
fx_ring_width = 1;
fx_spark_length = 9;

// The orange fireball (65% of ring radius) reaches 125% of the scout's size.
if (fx_scout_size > 0)
{
    fx_burst_radius = max(fx_burst_radius, fx_scout_size * 1.25 / (2 * 0.65));
    fx_flash_radius = max(fx_flash_radius, fx_scout_size * 0.32);
}

// Demo boss finale: larger shockwave and white ignition, without a long sequence.
if (fx_miniboss)
{
    fx_duration = 0.85;
    fx_flash_duration = 0.13;
    fx_flash_radius = 30;
    fx_burst_duration = 0.38;
    fx_burst_radius = 64;
    fx_spark_count = 34;
    fx_debris_count = 40;
    fx_launch_scale = 1.7;
    fx_debris_scale = 2.0;
    fx_ring_width = 2;
    fx_spark_length = 14;
}
fx_age = 0;
fx_particles = [];

for (var _i = 0; _i < fx_spark_count + fx_debris_count; _i++)
{
    var _debris = _i >= fx_spark_count;
    var _angle = _debris ? random_range(25, 155) : random(360);
    var _speed = _debris ? random_range(55, 105) : random_range(90, 175);
    _speed *= fx_launch_scale;
    var _life = _debris ? fx_duration : random_range(0.18, 0.30) * (fx_miniboss ? 1.7 : 1);
    array_push(fx_particles, {
        px: x + random_range(-3, 3), py: y + random_range(-3, 3),
        vx: lengthdir_x(_speed, _angle), vy: lengthdir_y(_speed, _angle),
        life: _life, duration: _life, debris: _debris,
        angle: random(360), spin: random_range(-360, 360),
        size: random_range(1.5, 3) * fx_debris_scale
    });
}
