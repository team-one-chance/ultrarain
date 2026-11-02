var _alpha = clamp(age / 0.18, 0, 1);
var _color = hit_flash > 0 ? (shield_hp > 0 ? c_yellow : c_white) : c_aqua;
var _left = bbox_left;
var _top = bbox_top;
var _right = bbox_right;
var _bottom = bbox_bottom;
draw_set_alpha(_alpha * 0.18);
draw_set_color(_color);
draw_rectangle(_left, _top, _right, _bottom, false);
draw_set_alpha(_alpha);
draw_rectangle(_left, _top, _right, _bottom, true);
for (var _line = _top + (floor(age * 24) mod 6); _line < _bottom; _line += 6)
    draw_line(_left, _line, _right, _line);
draw_circle((_left + _right) / 2, (_top + _bottom) / 2, training_kind == 4 ? 7 : 10, true);
if (shield_hp > 0)
{
    draw_set_color(make_color_rgb(255, 190, 60));
    if (training_kind == 3 && instance_exists(o_Player))
    {
        var _side = sign(o_Player.x - x);
        var _plate = _side > 0 ? _right + 7 : _left - 7;
        draw_line_width(_plate, _top - 6, _plate, _bottom + 6, 4);
    }
    else draw_rectangle(_left - 5, _top - 5, _right + 5, _bottom + 5, true);
    draw_rectangle(_left, _top - 12, lerp(_left, _right, shield_hp / shield_hp_max), _top - 8, false);
}
draw_set_alpha(1);
draw_set_color(c_white);
