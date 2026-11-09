var _old_color = draw_get_color();
var _old_alpha = draw_get_alpha();
var _old_font = draw_get_font();
var _old_halign = draw_get_halign();
var _old_valign = draw_get_valign();
if (section == 2)
{
    var _dash_marker = note("bp dash");
    var _hint_x = _dash_marker.x + 128; // World pixels; above the big jump's takeoff.
    var _hint_y = _dash_marker.y - 144 + sin(elapsed * 2) * 3; // World pixels; gentle hologram hover.
    var _hint_scale = 2; // Text size multiplier; readable while approaching the jump.
    var _hint_alpha = 0.75 + 0.15 * sin(elapsed * 4); // Opacity; softly pulsing green projection.
    var _hint_text = string_upper(controls_key_name(controls_key("dash")))
        + " -> " + string_upper(controls_key_name(controls_key("jump")));
    draw_set_font(-1);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(64, 255, 128));
    // Faint offset copies give the lettering a projected halo.
    draw_set_alpha(_hint_alpha * 0.16);
    draw_text_transformed(_hint_x - 2, _hint_y, _hint_text, _hint_scale, _hint_scale, 0);
    draw_text_transformed(_hint_x + 2, _hint_y, _hint_text, _hint_scale, _hint_scale, 0);
    draw_text_transformed(_hint_x, _hint_y - 2, _hint_text, _hint_scale, _hint_scale, 0);
    draw_text_transformed(_hint_x, _hint_y + 2, _hint_text, _hint_scale, _hint_scale, 0);
    draw_set_alpha(_hint_alpha);
    draw_text_transformed(_hint_x, _hint_y, _hint_text, _hint_scale, _hint_scale, 0);
    var _hint_half_width = string_width(_hint_text) * _hint_scale * 0.5;
    draw_set_alpha(_hint_alpha * 0.35);
    draw_line(_hint_x - _hint_half_width, _hint_y + 22, _hint_x + _hint_half_width, _hint_y + 22);
    // A short travelling scan line reinforces the holographic appearance.
    var _scan_x = lerp(_hint_x - _hint_half_width, _hint_x + _hint_half_width, (elapsed * 0.4) mod 1);
    draw_set_alpha(_hint_alpha * 0.7);
    draw_line(_scan_x - 8, _hint_y + 22, _scan_x + 8, _hint_y + 22);
}
if (section == 1)
{
    var _start = note("spawn jump");
    var _hole = note("dead end");
    var _bottom = note("abyss tp");
    var _hole_x = (_hole.right + _bottom.right) / 2;
    var _route_y = _start.y - 128; // World pixels; raised 40 pixels to sit above the action while staying visible.
    var _spacing = 160; // World pixels between arrows; smaller values make a denser trail.
    var _across = max(1, ceil((_hole_x - _start.x - 80) / _spacing));
    var _down = max(1, ceil((_bottom.y - _route_y - 80) / _spacing));
    draw_set_color(c_aqua);
    for (var _i = 0; _i < _across + _down; ++_i)
    {
        var _vertical = _i >= _across;
        var _phase = elapsed * 3.5 - _i * 0.7; // Radians; staggered pulses travel toward the hole.
        var _bob = sin(_phase) * 6; // World pixels of gentle motion along the arrow direction.
        var _size = 24 + sin(_phase) * 2; // Half-length in world pixels: roughly 48-pixel arrows.
        var _ax = _vertical ? _hole_x : lerp(_start.x + 80, _hole_x - 80, _i / max(1, _across - 1));
        var _ay = _vertical ? lerp(_route_y + 64, _bottom.y - 64,
            (_i - _across) / max(1, _down - 1)) : _route_y;
        var _dx = _vertical ? 0 : 1;
        var _dy = _vertical ? 1 : 0;
        _ax += _dx * _bob;
        _ay += _dy * _bob;
        var _tip_x = _ax + _dx * _size;
        var _tip_y = _ay + _dy * _size;
        // Subdued holographic arrows leave the terrain readable while clearly marking the route.
        draw_set_alpha(0.24 + 0.12 * (0.5 + 0.5 * sin(_phase)));
        draw_line_width(_ax - _dx * _size, _ay - _dy * _size, _tip_x, _tip_y, 5);
        draw_line_width(_tip_x, _tip_y, _ax - _dy * _size * 0.65, _ay + _dx * _size * 0.65, 5);
        draw_line_width(_tip_x, _tip_y, _ax + _dy * _size * 0.65, _ay - _dx * _size * 0.65, 5);
    }
    draw_set_font(-1);
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_alpha(0.7 + 0.15 * sin(elapsed * 3.5));
    draw_text(_hole_x, _route_y - 44, "DROP HERE");
}
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
    draw_text((wall_gate.bbox_left + wall_gate.bbox_right) / 2, wall_gate.bbox_top - 8, "SLIDE DOWN A WALL TO OPEN");
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
