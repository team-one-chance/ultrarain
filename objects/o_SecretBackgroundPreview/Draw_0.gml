if (preview_finished || preview_map == -1) exit;
var _cam = view_camera[0];
if (_cam == -1) exit;
var _tw = tilemap_get_tile_width(preview_map);
var _th = tilemap_get_tile_height(preview_map);
var _set = tilemap_get_tileset(preview_map);
var _left = max(x, floor(camera_get_view_x(_cam) / _tw) * _tw);
var _top = max(y, floor(camera_get_view_y(_cam) / _th) * _th);
var _right = min(x + preview_width, camera_get_view_x(_cam) + camera_get_view_width(_cam) + _tw);
var _bottom = min(y + preview_height, camera_get_view_y(_cam) + camera_get_view_height(_cam) + _th);
var _old_alpha = draw_get_alpha();
var _old_color = draw_get_color();
draw_set_color(c_white);
for (var _yy = _top; _yy < _bottom; _yy += _th)
{
    for (var _xx = _left; _xx < _right; _xx += _tw)
    {
        var _edge_x = min(_xx + _tw / 2 - x, x + preview_width - _xx - _tw / 2);
        var _edge_y = min(_yy + _th / 2 - y, y + preview_height - _yy - _th / 2);
        draw_set_alpha(clamp(min(_edge_x, _edge_y) / preview_fade, 0, 1));
        var _data = tilemap_get_at_pixel(preview_map, _xx, _yy);
        draw_tile(_set, _data, 0, _xx, _yy);
    }
}
draw_set_alpha(_old_alpha);
draw_set_color(_old_color);
