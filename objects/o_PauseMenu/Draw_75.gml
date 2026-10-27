if (!opened) exit;
var _font = draw_get_font();
var _color = draw_get_color();
var _alpha = draw_get_alpha();
var _halign = draw_get_halign();
var _valign = draw_get_valign();
var _layout = pause_layout();
var _scale = _layout.scale;
var _fade = 1 - power(1 - clamp(menu_age / 0.18, 0, 1), 3);

// The dev controller draws the captured world beneath this panel.
draw_set_alpha(0.72 * _fade);
draw_set_color(c_black);
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
draw_set_alpha(0.96 * _fade);
draw_set_color(make_color_rgb(9, 15, 22));
draw_rectangle(_layout.x - _layout.width * 0.5, _layout.top,
    _layout.x + _layout.width * 0.5, _layout.top + _layout.height, false);
draw_set_alpha(_fade);
draw_set_color(accent);
draw_rectangle(_layout.x - _layout.width * 0.5, _layout.top,
    _layout.x + _layout.width * 0.5, _layout.top + 3 * _scale, false);
draw_set_font(f_Console);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text_transformed(_layout.x, _layout.top + 42 * _scale, "ULTRA RAIN", 0.7 * _scale, 0.7 * _scale, 0);
draw_set_color(c_white);
var _title = page == 0 ? "PAUSED" : (page == 1 ? "SETTINGS" : "CREDITS");
draw_text_transformed(_layout.x, _layout.top + 94 * _scale, _title, 1.7 * _scale, 1.7 * _scale, 0);
var _options = pause_options();
for (var _i = 0; _i < array_length(_options); _i++)
{
    var _y = _layout.row_top + (_i + 0.5) * _layout.row_height;
    draw_set_color(_i == selected ? c_white : make_color_rgb(155, 172, 187));
    draw_text_transformed(_layout.x, _y, _options[_i], _scale, _scale, 0);
    if (_i == selected)
    {
        var _ease = 1 - power(1 - clamp(selection_age / 0.24, 0, 1), 3);
        var _half_width = (string_width(_options[_i]) * 0.5 + 10) * _scale * _ease;
        draw_set_color(accent);
        draw_rectangle(_layout.x - _half_width, _y + 19 * _scale,
            _layout.x + _half_width, _y + 22 * _scale, false);
    }
}
if (page == 2)
{
    draw_set_color(c_white);
    draw_text_transformed(_layout.x, _layout.row_top + 130 * _scale,
        "Team One Chance", _scale, _scale, 0);
}
draw_set_color(make_color_rgb(110, 135, 152));
draw_text_transformed(_layout.x, _layout.top + _layout.height - 25 * _scale,
    "ESC back / resume   |   ENTER or click to select", 0.55 * _scale, 0.55 * _scale, 0);
draw_set_font(_font);
draw_set_color(_color);
draw_set_alpha(_alpha);
draw_set_halign(_halign);
draw_set_valign(_valign);
