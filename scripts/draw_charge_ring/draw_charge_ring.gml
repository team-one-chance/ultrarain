/// Draw during the Draw event, after drawing the enemy.
/// _progress: charge completion from 0 to 1.
/// _half_width / _half_height: half the enemy's visual size, in room pixels.
function draw_charge_ring(_cx, _cy, _half_width, _half_height, _progress,
    _color = c_red, _flash_alpha = undefined)
{
    _progress = clamp(_progress, 0, 1);

    var _scale = lerp(1.4, 1.2, _progress); // Size multiplier; decreasing values shrink inward.
    var _radius_x = _half_width * _scale; // Horizontal radius in room pixels.
    var _radius_y = _half_height * _scale; // Vertical radius in room pixels.
    var _stroke_half = 1; // Room pixels; half the total 2-pixel stroke width.
    var _segments = 64; // Oval subdivisions; higher values make it smoother.

    var _old_color = draw_get_color();
    var _old_alpha = draw_get_alpha();

    var _opacity = is_undefined(_flash_alpha) ? lerp(0.45, 1, _progress)
        : clamp(_flash_alpha, 0, 1); // Ring opacity, 0-1; explicit flashing overrides charge opacity.
    draw_set_alpha(_opacity);

    draw_set_color(_color);

    draw_primitive_begin(pr_trianglestrip);
    for (var _i = 0; _i <= _segments; ++_i)
    {
        var _angle = _i * 360 / _segments; // Degrees around the oval.
        var _cos = dcos(_angle);
        var _sin = dsin(_angle);

        draw_vertex(
            _cx + (_radius_x + _stroke_half) * _cos,
            _cy + (_radius_y + _stroke_half) * _sin
        );
        draw_vertex(
            _cx + (_radius_x - _stroke_half) * _cos,
            _cy + (_radius_y - _stroke_half) * _sin
        );
    }
    draw_primitive_end();

    draw_set_alpha(_old_alpha);
    draw_set_color(_old_color);
}
