// Robot death: white flash, orange shockwave, sparks and metal fragments.
fx_age = 0;
fx_duration = 0.9;
fx_radius = 48;
fx_sparks = [];
fx_debris = [];

repeat (32)
{
    var launch_angle = random(360);
    var launch_speed = random_range(100, 280);
    var lifetime = random_range(0.25, 0.65);
    array_push(fx_sparks, {
        px: x, py: y,
        vx: lengthdir_x(launch_speed, launch_angle),
        vy: lengthdir_y(launch_speed, launch_angle),
        life: lifetime, max_life: lifetime,
        colour: choose(c_white, c_yellow, make_color_rgb(255, 120, 30))
    });
}

repeat (10)
{
    var launch_angle = random_range(15, 165);
    var launch_speed = random_range(90, 210);
    array_push(fx_debris, {
        px: x + random_range(-8, 8), py: y + random_range(-8, 8),
        vx: lengthdir_x(launch_speed, launch_angle),
        vy: lengthdir_y(launch_speed, launch_angle),
        angle: random(360), spin: random_range(-540, 540),
        size: random_range(2, 5),
        colour: choose(make_color_rgb(110, 120, 135), c_silver, c_white)
    });
}
