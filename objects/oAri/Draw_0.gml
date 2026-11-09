if (ari_state == "waiting" || ari_state == "closing" || ari_state == "opening") exit;
if (ari_state != "arriving" && ari_state != "departing")
{
    draw_self();
    exit;
}

// Visual effects (VFX): reconstruct horizontal sprite strips amid green code and displaced scan lines.
var _duration = ari_state == "arriving" ? ari_scene_config.arrive_seconds : ari_scene_config.depart_seconds;
var _progress = clamp(ari_elapsed / _duration, 0, 1);
var _reveal = ari_state == "arriving" ? _progress : 1 - _progress;
var _noise_tick = floor(ari_elapsed * 30); // Glitch changes per second; independent of rendering frame rate.
var _sprite_w = sprite_get_width(sprite_index);
var _sprite_h = sprite_get_height(sprite_index);
var _strip_h = 4; // Sprite pixels per digital slice; smaller values create finer fragmentation.
var _glitch = sin(pi * _progress); // Peak distortion halfway through either transition.
var _old_color = draw_get_color();
var _old_alpha = draw_get_alpha();
var _old_font = draw_get_font();
var _old_halign = draw_get_halign();
var _old_valign = draw_get_valign();
for (var _row = 0; _row < _sprite_h; _row += _strip_h)
{
    var _seed = sin(_row * 14.73 + _noise_tick * 9.17);
    var _threshold = clamp((_sprite_h - _row) / _sprite_h + _seed * 0.12, 0, 1);
    if (_reveal <= _threshold) continue;
    var _offset = _seed * 14 * _glitch; // Room pixels; horizontal displacement peaks during reconstruction.
    var _px = x - sprite_get_xoffset(sprite_index) * image_xscale + _offset;
    var _py = y + (_row - sprite_get_yoffset(sprite_index)) * image_yscale;
    var _height = min(_strip_h, _sprite_h - _row);
    draw_sprite_part_ext(sprite_index, image_index, 0, _row, _sprite_w, _height,
        _px + 3 * _glitch, _py, image_xscale, image_yscale, make_color_rgb(20, 255, 110), 0.55 * _glitch);
    draw_sprite_part_ext(sprite_index, image_index, 0, _row, _sprite_w, _height,
        _px, _py, image_xscale, image_yscale,
        merge_color(c_white, make_color_rgb(50, 255, 140), _glitch * 0.75), 0.5 + 0.5 * _reveal);
}
draw_set_font(f_Console);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
for (var _column = 0; _column < 6; ++_column)
{
    var _column_x = x + ((_column + 0.5) * _sprite_w / 6 - sprite_get_xoffset(sprite_index)) * image_xscale;
    var _head = (ari_elapsed * 170 + _column * 31) mod (_sprite_h + 32); // Pixels per second; descending code trails.
    for (var _tail = 0; _tail < 4; ++_tail)
    {
        var _code_y = _head - _tail * 9;
        if (_code_y < 0 || _code_y >= _sprite_h) continue;
        draw_set_color(_tail == 0 ? make_color_rgb(205, 255, 225) : make_color_rgb(20, 245, 90));
        draw_set_alpha(_glitch * (1 - _tail / 4));
        var _digit = (abs(_noise_tick * 7 + _column * 13 + _tail * 3) mod 2 == 0) ? "0" : "1";
        draw_text_transformed(_column_x, y + _code_y - sprite_get_yoffset(sprite_index), _digit, 0.35, 0.35, 0);
    }
}
draw_set_font(_old_font);
draw_set_color(_old_color);
draw_set_alpha(_old_alpha);
draw_set_halign(_old_halign);
draw_set_valign(_old_valign);
