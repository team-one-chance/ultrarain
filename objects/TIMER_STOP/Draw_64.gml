var _color = draw_get_color();
var _alpha = draw_get_alpha();
var _font = draw_get_font();
var _halign = draw_get_halign();
var _valign = draw_get_valign();

var _total_ms = max(0, floor(elapsed_time * 1000));
var _minutes = floor(_total_ms / 60000);
var _seconds = floor(_total_ms / 1000) mod 60;
var _milliseconds = _total_ms mod 1000;
var _text = string(_minutes) + ":"
    + string_copy("0" + string(_seconds), string_length("0" + string(_seconds)) - 1, 2)
    + "." + string_copy("00" + string(_milliseconds), string_length("00" + string(_milliseconds)) - 2, 3);

draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(0.65);
draw_set_color(c_black);
draw_roundrect(208, 52, 348, 94, false);
draw_set_alpha(1);
draw_set_color(make_color_rgb(150, 160, 168));
draw_text(218, 54, "RUN TIME");
draw_set_color(c_white);
draw_text(218, 72, _text);

draw_set_color(_color);
draw_set_alpha(_alpha);
draw_set_font(_font);
draw_set_halign(_halign);
draw_set_valign(_valign);
