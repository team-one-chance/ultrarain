// A smaller version of the player's mechanical death burst.
// Motion and automatic cleanup use oPlayerExplosion's inherited Step event.
fx_age = 0;
fx_duration = 0.6;
fx_radius = 28;
fx_sparks = [];
fx_debris = [];

repeat (14)
{
    var launch_angle = random(360);
    var launch_speed = random_range(70, 180);
    var lifetime = random_range(0.18, 0.4);
    array_push(fx_sparks, {
        px: x, py: y,
        vx: lengthdir_x(launch_speed, launch_angle),
        vy: lengthdir_y(launch_speed, launch_angle),
        life: lifetime, max_life: lifetime,
        colour: choose(c_white, c_yellow, make_color_rgb(255, 120, 30))
    });
}

repeat (5)
{
    var launch_angle = random_range(15, 165);
    var launch_speed = random_range(60, 130);
    array_push(fx_debris, {
        px: x + random_range(-5, 5), py: y + random_range(-5, 5),
        vx: lengthdir_x(launch_speed, launch_angle),
        vy: lengthdir_y(launch_speed, launch_angle),
        angle: random(360), spin: random_range(-360, 360),
        size: random_range(1.5, 3),
        colour: choose(make_color_rgb(110, 120, 135), c_silver)
    });
}
