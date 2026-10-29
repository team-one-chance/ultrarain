draw_self();

var _old_colour = draw_get_color();
var _old_alpha = draw_get_alpha();
var _cos = dcos(image_angle);
var _sin = dsin(image_angle);

for (var _i = 0; _i < array_length(wire_arcs); _i++)
{
    var _arc = wire_arcs[_i];
    var _local_x = _arc.anchor_x * image_xscale;
    var _local_y = _arc.anchor_y * image_yscale;
    var _origin_x = x + _local_x * _cos + _local_y * _sin;
    var _origin_y = y - _local_x * _sin + _local_y * _cos;
    var _fade = _arc.life / _arc.duration;

    // Soft blue outline with a crisp white core.
    for (var _pass = 0; _pass < 2; _pass++)
    {
        draw_set_color((_pass == 0) ? make_color_rgb(90, 180, 255) : c_white);
        draw_set_alpha(_old_alpha * _fade * ((_pass == 0) ? 0.35 : 1));
        var _width = (_pass == 0) ? 3 : 1;

        for (var _point = 1; _point < array_length(_arc.points); _point++)
        {
            var _from = _arc.points[_point - 1];
            var _to = _arc.points[_point];
            draw_line_width(
                _origin_x + _from.x, _origin_y + _from.y,
                _origin_x + _to.x, _origin_y + _to.y,
                _width
            );
        }
    }
}

draw_set_color(_old_colour);
draw_set_alpha(_old_alpha);
