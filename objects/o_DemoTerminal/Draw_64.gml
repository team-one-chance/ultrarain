if (!reading) exit;

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

var _pw = min(900, _gw - 40);
var _ph = min(420, _gh - 40);
var _px = (_gw - _pw) * 0.5;
var _py = (_gh - _ph) * 0.5;

draw_set_color(c_black);
draw_set_alpha(0.75);
draw_rectangle(0, 0, _gw, _gh, false);

draw_set_alpha(1);
draw_set_color(make_color_rgb(18, 22, 28));
draw_rectangle(
    _px, _py,
    _px + _pw, _py + _ph,
    false
);

draw_set_color(c_white);
draw_rectangle(
    _px, _py,
    _px + _pw, _py + _ph,
    true
);

draw_set_halign(fa_center);
draw_text(_gw * 0.5, _py + 24, terminal_title);

draw_set_halign(fa_left);
draw_text_ext(
    _px + 32,
    _py + 70,
    terminal_display_text,
    24,
    _pw - 64
);

draw_set_halign(fa_center);
draw_text(
    _gw * 0.5,
    _py + _ph - 36,
    "[E] / ESC — CLOSE"
);

draw_set_halign(fa_left);
draw_set_alpha(1);
draw_set_color(c_white);