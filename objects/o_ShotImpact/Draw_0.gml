var _old_color = draw_get_color();
var _old_alpha = draw_get_alpha();
if (parry_ring_life > 0)
{
    var _progress = 1 - parry_ring_life / parry_ring_duration;
    var _radius = lerp(5, parry_ring_radius, 1 - sqr(1 - _progress));
    var _fade = sqr(1 - _progress);
    // Segmented line ring keeps its width independent of draw-circle precision.
    for (var _segment = 0; _segment < 48; ++_segment)
    {
        var _a = _segment * 360 / 48;
        var _b = (_segment + 1) * 360 / 48;
        draw_set_color(impact_energy ? spark_color_end : make_color_rgb(255, 115, 25));
        draw_set_alpha(_fade * 0.45);
        draw_line_width(x + lengthdir_x(_radius, _a), y + lengthdir_y(_radius, _a),
            x + lengthdir_x(_radius, _b), y + lengthdir_y(_radius, _b), 4);
        draw_set_color(impact_energy ? c_white : make_color_rgb(255, 225, 145));
        draw_set_alpha(_fade);
        draw_line_width(x + lengthdir_x(_radius, _a), y + lengthdir_y(_radius, _a),
            x + lengthdir_x(_radius, _b), y + lengthdir_y(_radius, _b), 1);
    }
}
// Layered localized glow, radial speed rays, and glowing fragments share the contact origin.
if (impact_energy)
{
    var _energy_fade = clamp(parry_ring_life / parry_ring_duration, 0, 1);
    for (var _glow = 3; _glow >= 1; --_glow)
    {
        draw_set_color(spark_color_end);
        draw_set_alpha(_energy_fade * _energy_fade * 0.09 * impact_strength);
        draw_circle(x, y, flash_radius * (1 + _glow * 0.7) * _energy_fade, false);
    }
    var _travel = 1 - sqr(_energy_fade);
    for (var _ray = 0; _ray < array_length(energy_rays); ++_ray)
    {
        var _r = energy_rays[_ray];
        var _inner = _r.reach * _travel * 0.3;
        var _outer = _r.reach * _travel;
        draw_set_color(spark_color_end);
        draw_set_alpha(_energy_fade * 0.5);
        draw_line_width(x + lengthdir_x(_inner, _r.angle), y + lengthdir_y(_inner, _r.angle),
            x + lengthdir_x(_outer, _r.angle), y + lengthdir_y(_outer, _r.angle), 4 * _energy_fade + 1);
        draw_set_color(c_white);
        draw_set_alpha(_energy_fade);
        draw_line_width(x + lengthdir_x(_inner, _r.angle), y + lengthdir_y(_inner, _r.angle),
            x + lengthdir_x(_outer, _r.angle), y + lengthdir_y(_outer, _r.angle), 1);
    }
    for (var _fragment = 0; _fragment < array_length(energy_fragments); ++_fragment)
    {
        var _f = energy_fragments[_fragment];
        var _fade = _f.life / _f.duration;
        draw_set_color(spark_color_end);
        draw_set_alpha(_fade * 0.25);
        draw_circle(_f.px, _f.py, 5 * _fade, false);
        draw_set_color(c_white);
        draw_set_alpha(_fade);
        var _dx = lengthdir_x(4 * _fade, _f.angle);
        var _dy = lengthdir_y(4 * _fade, _f.angle);
        draw_triangle(_f.px + _dx, _f.py + _dy, _f.px - _dy * 0.5, _f.py + _dx * 0.5,
            _f.px + _dy * 0.5, _f.py - _dx * 0.5, false);
    }
}
if (flash_life > 0)
{
    draw_set_color(spark_color_start);
    draw_set_alpha(flash_life / flash_duration);
    draw_circle(x, y, flash_radius * flash_life / flash_duration, false);
}
for (var _i = 0; _i < array_length(particles); _i++)
{
    var _p = particles[_i];
    var _fade = clamp(_p.life / _p.duration, 0, 1);
    if (_p.dust)
    {
        draw_set_color(make_color_rgb(150, 145, 135));
        draw_set_alpha(_fade * 0.30);
        draw_circle(_p.px, _p.py, 1 + (1 - _fade) * 2, false);
    }
    else
    {
        draw_set_color(merge_color(spark_color_end, spark_color_start, _fade));
        draw_set_alpha(_fade);
        var _angle = point_direction(0, 0, _p.vx, _p.vy);
        draw_line_width(_p.px, _p.py,
            _p.px - lengthdir_x(spark_tail_length * _fade, _angle),
            _p.py - lengthdir_y(spark_tail_length * _fade, _angle), spark_width);
    }
}
draw_set_color(_old_color);
draw_set_alpha(_old_alpha);
