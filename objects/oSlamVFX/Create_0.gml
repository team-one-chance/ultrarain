// Appearance settings — change these here.
fx_duration = 0.42;
fx_ring_flatness = 0.5; // Lower = flatter ground ring.
fx_ring_width = 2.5;
fx_particle_count = 18; // Base count; strong slams get more.
fx_colour = make_color_rgb(90, 220, 255);
fx_colour_secondary = make_color_rgb(53, 40, 193);
fx_colour_flash = c_white;

fx_age = 0;
fx_radius = 30;
fx_strength = 1;
fx_sparks = [];

start_slam_vfx = function(_radius, _power)
{
    fx_age = 0;
    fx_radius = max(8, _radius);
    fx_strength = clamp(sqrt(max(1, _power)), 1, 3);
    fx_sparks = [];

    var amount = min(54, round(fx_particle_count * fx_strength));
    var spawn_width = min(24, fx_radius * 0.35);

    repeat (amount)
    {
        var launch_angle = random_range(20, 160);
        var launch_speed = random_range(90, 190) * fx_strength;
        var lifetime = random_range(0.18, 0.38);

        array_push(fx_sparks, {
            px: x + random_range(-spawn_width, spawn_width),
            py: y - random_range(2, 5),
            vx: lengthdir_x(launch_speed, launch_angle),
            vy: lengthdir_y(launch_speed, launch_angle),
            life: lifetime,
            max_life: lifetime,
            width: random_range(1, 2) * min(fx_strength, 2),
            colour: choose(fx_colour, fx_colour_secondary, fx_colour_flash)
        });
    }
};
