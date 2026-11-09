if (ari_state == "waiting" || ari_state == "ambient") exit;
if (!instance_exists(ari_player) || ari_player.pHP <= 0) exit;

var _old_font = draw_get_font();
var _old_color = draw_get_color();
var _old_alpha = draw_get_alpha();
var _old_halign = draw_get_halign();
var _old_valign = draw_get_valign();
draw_set_font(f_Console);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
var _bar_width = _gui_w * ari_scene_config.bar_fraction * ari_bars;
draw_set_alpha(1);
draw_set_color(c_black);
draw_rectangle(0, 0, _bar_width, _gui_h, false);
draw_rectangle(_gui_w - _bar_width, 0, _gui_w, _gui_h, false);
if (ari_state != "prompt" && ari_state != "dialogue")
{
    draw_set_font(_old_font);
    draw_set_color(_old_color);
    draw_set_alpha(_old_alpha);
    draw_set_halign(_old_halign);
    draw_set_valign(_old_valign);
    exit;
}
var _scale = clamp(min(_gui_w / 1280, _gui_h / 720), 0.4, 1.5); // GUI scale; keeps the conversation readable at smaller resolutions.
var _text_scale = _scale * ari_scene_config.dialogue_text_scale;
var _camera = view_camera[0];
var _name_x = _gui_w * 0.5;
var _name_y = _gui_h * 0.4;
if (_camera != -1)
{
    // Project the name into GUI space so it stays readable above Ari through world lighting.
    _name_x = ((bbox_left + bbox_right) * 0.5 - camera_get_view_x(_camera))
        * _gui_w / camera_get_view_width(_camera);
    _name_y = (bbox_top - camera_get_view_y(_camera))
        * _gui_h / camera_get_view_height(_camera) - 10 * _scale; // GUI pixels above Ari's head.
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_color(c_black);
    draw_text_transformed(_name_x + _scale, _name_y + _scale, ari_display_name, _text_scale, _text_scale, 0);
    draw_set_color(c_white);
    draw_text_transformed(_name_x, _name_y, ari_display_name, _text_scale, _text_scale, 0);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
if (ari_state == "prompt")
{
    // A compact speech bubble follows the character's projected head position for both Ari and Samuel.
    var _prompt = controls_key_name(controls_key("interact")) + " - TALK";
    var _appear = 1 - power(1 - clamp(ari_elapsed / 0.18, 0, 1), 3); // Seconds to fade and lift the popup into place.
    var _bubble_w = string_width(_prompt) * _text_scale + 24 * _scale;
    var _bubble_h = string_height(_prompt) * _text_scale + 16 * _scale;
    var _bubble_x = clamp(_name_x, _bar_width + _bubble_w * 0.5 + 8 * _scale,
        _gui_w - _bar_width - _bubble_w * 0.5 - 8 * _scale);
    var _bubble_bottom = max(_bubble_h + 8 * _scale,
        _name_y - string_height(ari_display_name) * _text_scale - 10 * _scale + (1 - _appear) * 6 * _scale);
    var _bubble_top = _bubble_bottom - _bubble_h;
    draw_set_alpha(_appear * 0.95);
    draw_set_color(make_color_rgb(12, 23, 31));
    draw_roundrect(_bubble_x - _bubble_w * 0.5, _bubble_top,
        _bubble_x + _bubble_w * 0.5, _bubble_bottom, false);
    draw_triangle(_bubble_x - 5 * _scale, _bubble_bottom - _scale,
        _bubble_x + 5 * _scale, _bubble_bottom - _scale, _bubble_x, _bubble_bottom + 6 * _scale, false);
    draw_set_alpha(_appear);
    draw_set_color(make_color_rgb(110, 195, 210));
    draw_roundrect(_bubble_x - _bubble_w * 0.5, _bubble_top,
        _bubble_x + _bubble_w * 0.5, _bubble_bottom, true);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text_transformed(_bubble_x, (_bubble_top + _bubble_bottom) * 0.5,
        _prompt, _text_scale, _text_scale, 0);
    draw_set_font(_old_font);
    draw_set_color(_old_color);
    draw_set_alpha(_old_alpha);
    draw_set_halign(_old_halign);
    draw_set_valign(_old_valign);
    exit;
}
var _padding = 14 * _scale; // GUI pixels between text and the panel edge.
var _width = min(ari_scene_config.dialogue_width * _scale, _gui_w - 2 * _bar_width - 2 * _padding);
var _text_width = (_width - 2 * _padding) / _text_scale;
var _full_text = ari_dialogue[ari_dialogue_index];
var _text = string_copy(_full_text, 1, floor(ari_text_chars));
var _key_name = controls_key_name(controls_key("interact"));
var _hint = _key_name + " - CONTINUE";
if (ari_state == "dialogue" && ari_text_chars < string_length(_full_text)) _hint = _key_name + " - REVEAL";
var _text_height = string_height_ext(_full_text, -1, _text_width) * _text_scale; // Reserve full line height so typing never resizes the panel.
var _height = _text_height + 74 * _scale;
var _left = (_gui_w - _width) * 0.5;
var _top = _gui_h - _height - 32 * _scale;

draw_set_alpha(0.94);
draw_set_color(make_color_rgb(12, 17, 24));
draw_rectangle(_left, _top, _left + _width, _top + _height, false);
draw_set_alpha(1);
draw_set_color(make_color_rgb(110, 195, 210));
draw_rectangle(_left, _top, _left + _width, _top + _height, true);
draw_text_transformed(_left + _padding, _top + 10 * _scale, string_upper(ari_display_name), _text_scale, _text_scale, 0);
draw_set_color(c_white);
draw_text_ext_transformed(_left + _padding, _top + 32 * _scale,
    _text, -1, _text_width, _text_scale, _text_scale, 0);
draw_set_color(make_color_rgb(160, 175, 185));
draw_text_transformed(_left + _padding, _top + _height - 26 * _scale, _hint, _text_scale, _text_scale, 0);

draw_set_font(_old_font);
draw_set_color(_old_color);
draw_set_alpha(_old_alpha);
draw_set_halign(_old_halign);
draw_set_valign(_old_valign);
