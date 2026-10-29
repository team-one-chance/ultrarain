var _old_colour = draw_get_color();
var _old_alpha = draw_get_alpha();
// Single fireball and thin shockwave, like the player's smaller counterpart.
if (fx_age < fx_burst_duration)
{
    var _burst = clamp(fx_age / fx_burst_duration, 0, 1);
    var _radius = lerp(4, fx_burst_radius, 1 - power(1 - _burst, 2));
    draw_set_color(fx_fire_colour);
    draw_set_alpha(0.85 * power(1 - _burst, 2));
    draw_circle(x, y, _radius * 0.65, false);
    // Hot yellow center holds its brightness before the fireball fades.
    draw_set_color(fx_core_colour);
    draw_set_alpha(power(1 - _burst, 2));
    draw_circle(x, y, _radius * 0.45 * (1 - _burst * 0.5), false);
    draw_set_color(c_yellow);
    draw_set_alpha(min(1, 1.6 * (1 - _burst)));
    for (var _segment = 0; _segment < 24; _segment++)
    {
        var _a = _segment * 15;
        draw_line_width(x + lengthdir_x(_radius, _a), y + lengthdir_y(_radius, _a),
            x + lengthdir_x(_radius, _a + 15), y + lengthdir_y(_radius, _a + 15),
            fx_ring_width);
    }
}
if (fx_age < fx_flash_duration)
{
    var _flash = 1 - fx_age / fx_flash_duration;
    draw_set_color(c_white);
    draw_set_alpha(_flash);
    var _flash_size = fx_miniboss ? fx_flash_radius * (1 + (1 - _flash) * 0.5)
        : fx_flash_radius * (0.5 + 0.5 * _flash);
    draw_circle(x, y, _flash_size, false);
}
for (var _i = 0; _i < array_length(fx_particles); _i++)
{
    var _p = fx_particles[_i];
    var _fade = clamp(_p.life / _p.duration, 0, 1);
    draw_set_alpha(min(1, _fade * 2));
    draw_set_color(_p.debris ? merge_color(make_color_rgb(130, 110, 90), fx_fire_colour, _fade)
        : merge_color(fx_fire_colour, fx_core_colour, _fade));
    var _angle = _p.debris ? _p.angle : point_direction(0, 0, _p.vx, _p.vy);
    var _length = _p.debris ? _p.size : fx_spark_length * _fade;
    if (_p.debris)
    {
        var _dx = lengthdir_x(_length, _angle);
        var _dy = lengthdir_y(_length, _angle);
        var _sx = lengthdir_x(_length * 0.5, _angle + 90);
        var _sy = lengthdir_y(_length * 0.5, _angle + 90);
        draw_triangle(_p.px + _dx, _p.py + _dy,
            _p.px - _dx + _sx, _p.py - _dy + _sy,
            _p.px - _dx - _sx, _p.py - _dy - _sy, false);
    }
    else
    {
        draw_line_width(_p.px, _p.py,
            _p.px - lengthdir_x(_length, _angle),
            _p.py - lengthdir_y(_length, _angle), 1);
    }
}
draw_set_color(_old_colour);
draw_set_alpha(_old_alpha);
