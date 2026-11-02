var _old_color = draw_get_color();
var _old_alpha = draw_get_alpha();
var _old_font = draw_get_font();
var _old_halign = draw_get_halign();
var _old_valign = draw_get_valign();
var _portal = teleport_marker();
if (!is_undefined(_portal))
{
    var _glow = 0.55 + 0.15 * sin(elapsed * 5); // Opacity; a gentle pulse marks loading points without blocking the view.
    draw_set_color(_portal.ready ? c_aqua : make_color_rgb(80, 140, 190));
    draw_set_alpha(_glow * 0.25);
    draw_rectangle(_portal.x - _portal.width / 2, _portal.y - _portal.height / 2,
        _portal.x + _portal.width / 2, _portal.y + _portal.height / 2, false);
    draw_set_alpha(_glow);
    draw_rectangle(_portal.x - _portal.width / 2, _portal.y - _portal.height / 2,
        _portal.x + _portal.width / 2, _portal.y + _portal.height / 2, true);
    for (var _line = -_portal.height / 2 + ((elapsed * 28) mod 8); _line < _portal.height / 2; _line += 8)
        draw_line(_portal.x - _portal.width / 2, _portal.y + _line, _portal.x + _portal.width / 2, _portal.y + _line);
    draw_set_font(-1);
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_alpha(1);
    draw_text(_portal.x, _portal.y - _portal.height / 2 - 8, "TRANSFER");
}
if (instance_exists(wall_gate))
{
    draw_set_alpha(0.8);
    draw_set_color(c_aqua);
    draw_rectangle(wall_gate.bbox_left, wall_gate.bbox_top, wall_gate.bbox_right, wall_gate.bbox_bottom, true);
    draw_set_font(-1);
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_text((wall_gate.bbox_left + wall_gate.bbox_right) / 2, wall_gate.bbox_top - 8, "WALL HOLD REQUIRED");
}
if (section == 0)
{
    draw_set_color(c_aqua);
    draw_circle(mouse_x, mouse_y, 5, true);
    draw_set_color(c_white);
}
if (terminal_ready)
{
    var _terminal = note("terminal lucidity");
    // A slowly breathing radial glyph, independent of any production character art.
    var _radius = 24 + sin(elapsed * 1.4) * 4;
    draw_set_color(c_aqua);
    draw_set_alpha(0.85);
    for (var _ray = 0; _ray < 12; ++_ray)
    {
        var _angle = _ray * 30 + sin(elapsed * 0.4) * 8;
        var _length = _radius + sin(elapsed + _ray) * 5;
        draw_line_width(_terminal.x + lengthdir_x(9, _angle), _terminal.y + lengthdir_y(9, _angle),
            _terminal.x + lengthdir_x(_length, _angle), _terminal.y + lengthdir_y(_length, _angle), 3);
    }
    draw_set_alpha(1);
    draw_set_color(c_white);

}
draw_set_font(_old_font);
draw_set_halign(_old_halign);
draw_set_valign(_old_valign);
draw_set_color(_old_color);
draw_set_alpha(_old_alpha);
