// Appearance settings — change these here.
fx_duration = 0.42;
fx_ring_flatness = 0.5; // Lower = flatter ground ring.
fx_ring_width = 2.5;
fx_particle_count = 18; // Base count; strong slams get more.
fx_colour = make_color_rgb(90, 220, 255);
fx_colour_secondary = make_color_rgb(53, 40, 193);
fx_colour_flash = c_white;
if (!variable_instance_exists(id, "fx_breaker")) fx_breaker = false;
fx_defer_to_lighting = false;
fx_wind_puffs = [];
if (fx_breaker)
{
    fx_duration = 0.28;
    fx_colour = make_color_rgb(245, 248, 250);
    fx_colour_secondary = make_color_rgb(205, 215, 220);
}

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
    fx_wind_puffs = [];
    if (fx_breaker)
    {
        // 32px blocks: keep the pressure burst within two blocks on either side.
        fx_radius = min(fx_radius, 64);
        for (var _i = 0; _i < 14; _i++)
        {
            array_push(fx_wind_puffs, {
                side: (_i mod 2) == 0 ? -1 : 1,
                delay: random_range(0, 0.045), duration: random_range(0.15, 0.23),
                spread: random_range(0.45, 0.8), lift: random_range(2, 7),
                size: random_range(2.5, 5)
            });
        }
        return;
    }

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

// A floor-hugging ribbon curls upward at the advancing edge of the gust.
draw_pressure_crescent = function(_side, _front, _height, _width, _alpha)
{
    var _x0 = _front * 0.12;
    var _x1 = _front * 0.78;
    var _x2 = _front;
    var _x3 = _front - _height * 0.45;
    draw_primitive_begin(pr_trianglestrip);
    for (var _i = 0; _i <= 24; _i++)
    {
        var _t = _i / 24;
        var _u = 1 - _t;
        var _taper = power(max(0, sin(pi * _t)), 0.7);
        var _px = _u * _u * _u * _x0 + 3 * _u * _u * _t * _x1
            + 3 * _u * _t * _t * _x2 + _t * _t * _t * _x3;
        var _py = -2 - _height * (0.6 * _u * _t * _t + _t * _t * _t);
        var _dx = 3 * _u * _u * (_x1 - _x0) + 6 * _u * _t * (_x2 - _x1)
            + 3 * _t * _t * (_x3 - _x2);
        var _dy = -_height * (1.2 * _u * _t + 2.4 * _t * _t);
        var _length = max(0.001, sqrt(_dx * _dx + _dy * _dy));
        var _nx = -_dy / _length * _width * _taper * 0.5;
        var _ny = _dx / _length * _width * _taper * 0.5;
        draw_vertex_color(x + _side * (_px + _nx), y + _py + _ny,
            fx_colour, _alpha * _taper);
        draw_vertex_color(x + _side * (_px - _nx), y + _py - _ny,
            fx_colour_secondary, _alpha * _taper * 0.35);
    }
    draw_primitive_end();
};

draw_breaker_pressure = function()
{
    var _old_color = draw_get_color();
    var _old_alpha = draw_get_alpha();
    // Low pale puffs follow the gust instead of spraying sparks into the air.
    for (var _i = 0; _i < array_length(fx_wind_puffs); _i++)
    {
        var _puff = fx_wind_puffs[_i];
        var _time = fx_age - _puff.delay;
        if (_time <= 0 || _time >= _puff.duration) continue;
        var _p = _time / _puff.duration;
        var _ease = 1 - power(1 - _p, 3);
        var _px = x + _puff.side * fx_radius * _puff.spread * _ease;
        var _py = y - 2 - _puff.lift * _p;
        var _size = _puff.size * (0.5 + _p);
        draw_set_color(fx_colour_secondary);
        draw_set_alpha(0.16 * sin(pi * _p));
        draw_ellipse(_px - _size, _py - _size * 0.5,
            _px + _size, _py + _size * 0.5, false);
    }
    draw_set_alpha(1);
    for (var _side = -1; _side <= 1; _side += 2)
    {
        // Three staggered contours create the impression of a rolling air blast.
        for (var _wave = 0; _wave < 3; _wave++)
        {
            var _time = fx_age - _wave * 0.022;
            if (_time < 0 || _time >= 0.22) continue;
            var _p = _time / 0.22;
            var _ease = 1 - power(1 - _p, 3);
            var _front = lerp(7, fx_radius - _wave * 5, _ease);
            var _height = lerp(5, 18 - _wave * 3, _ease);
            var _alpha = power(1 - _p, 0.8) * (1 - _wave * 0.25);
            draw_pressure_crescent(_side, _front, _height,
                (3.5 - _wave * 0.6) * (1 - _p * 0.5), _alpha);
            // Tapered shear streaks pull the eye outward along the floor.
            var _tail = max(0, _front - lerp(24, 7, _p));
            var _floor_y = y - 2 - _wave * 3;
            draw_set_color(fx_colour);
            draw_set_alpha(_alpha * 0.5);
            draw_triangle(x + _side * _front, _floor_y,
                x + _side * _tail, _floor_y - 0.8,
                x + _side * _tail, _floor_y + 0.8, false);
            draw_set_alpha(1);
        }
    }
    // One sharp compression flash at contact; the gust takes over immediately.
    if (fx_age < 0.045)
    {
        var _flash = 1 - fx_age / 0.045;
        draw_set_color(c_white);
        draw_set_alpha(_flash * 0.85);
        draw_triangle(x - 19, y - 2, x, y - 8 * _flash - 2, x + 19, y - 2, false);
        draw_set_alpha(_flash * 0.45);
        draw_ellipse(x - 22, y - 4, x + 22, y, false);
    }
    draw_set_color(_old_color);
    draw_set_alpha(_old_alpha);
};

// Draw bright impact elements after ambient lighting when necessary.
draw_slam_energy = function()
{
if (fx_breaker) { draw_breaker_pressure(); return; }
var old_colour = draw_get_color();
var old_alpha = draw_get_alpha();

var progress = clamp(fx_age / fx_duration, 0, 1);
var expansion = 1 - power(1 - progress, 3);
var radius = lerp(4, fx_radius, expansion);
var opacity = power(1 - progress, 2);
var ring_y = y - 2;

// Brief white flash at the centre.
if (progress < 0.25)
{
    var flash_alpha = 0.65 * (1 - progress / 0.25);
    var flash_width = min(36, fx_radius * 0.45) * (1 + progress);
    draw_set_color(fx_colour_flash);
    draw_set_alpha(flash_alpha);
    draw_ellipse(
        x - flash_width, ring_y - flash_width * 0.3,
        x + flash_width, ring_y + flash_width * 0.3,
        false
    );
}

// Two expanding elliptical rings on the ground.
// Line segments let us set ring thickness without a sprite or shader.
var segments = 48;
for (var ring = 0; ring < 2; ring++)
{
    var ring_radius = radius * (ring == 0 ? 1 : 0.72);
    var ring_alpha = opacity * (ring == 0 ? 0.9 : 0.45);
    var ring_width = fx_ring_width * (ring == 0 ? 1 : 0.65);

    draw_set_color(ring == 0 ? fx_colour : fx_colour_secondary);
    draw_set_alpha(ring_alpha);

    for (var segment = 0; segment < segments; segment++)
    {
        var angle_a = segment * 360 / segments;
        var angle_b = (segment + 1) * 360 / segments;

        draw_line_width(
            x + lengthdir_x(ring_radius, angle_a),
            ring_y + lengthdir_y(ring_radius * fx_ring_flatness, angle_a),
            x + lengthdir_x(ring_radius, angle_b),
            ring_y + lengthdir_y(ring_radius * fx_ring_flatness, angle_b),
            ring_width
        );
    }
}

// Sparks fly upward and fade into short streaks.
for (var i = 0; i < array_length(fx_sparks); i++)
{
    var spark = fx_sparks[i];
    var spark_alpha = clamp(spark.life / spark.max_life, 0, 1);
    var streak_x = clamp(spark.vx * 0.018, -18, 18);
    var streak_y = clamp(spark.vy * 0.018, -18, 18);

    draw_set_color(spark.colour);
    draw_set_alpha(spark_alpha);
    draw_line_width(
        spark.px, spark.py,
        spark.px - streak_x, spark.py - streak_y,
        spark.width
    );
}

draw_set_color(old_colour);
draw_set_alpha(old_alpha);
};
