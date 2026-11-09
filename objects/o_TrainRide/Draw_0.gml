for (var _i = 0; _i < array_length(departure_wall_tiles); _i++)
{
    var _tile = departure_wall_tiles[_i];
    draw_tile(_tile.tileset, _tile.data, 0,
        _tile.home_x - scenery_distance, _tile.home_y);
}

var _cam = view_camera[0];
if (_cam == -1) exit;
var _view_x = camera_get_view_x(_cam);
var _view_y = camera_get_view_y(_cam);
var _view_w = camera_get_view_width(_cam);
var _view_h = camera_get_view_height(_cam);

// Cover only the train/station section, not the whole tutorial.
var _draw_left = max(_view_x, train_left - 768);
var _draw_right = min(_view_x + _view_w, train_right + 2200);
var _draw_top = _view_y;
var _draw_bottom = _view_y + _view_h;
if (_draw_right <= _draw_left || _draw_bottom <= _draw_top) exit;
var _old_color = draw_get_color();
var _old_alpha = draw_get_alpha();
draw_set_alpha(1);
draw_set_color(c_black);
 // draw_rectangle(_draw_left, _draw_top, _draw_right, _draw_bottom, false);

var _spacing = 160;
var _offset = scenery_distance mod _spacing;
var _first_pillar = floor((_draw_left + _offset) / _spacing) * _spacing - _offset - _spacing;
draw_set_color(make_color_rgb(45, 45, 45));
draw_set_alpha(0.45);
for (var _pillar = _first_pillar; _pillar < _draw_right + _spacing; _pillar += _spacing)
{
    var _px1 = max(_draw_left, _pillar);
    var _px2 = min(_draw_right, _pillar + 24);
    if (_px2 > _px1)
        draw_rectangle(_px1, _draw_top, _px2, _draw_bottom, false);
}

draw_set_alpha(1);
var _rail_left = train_left + 4;
var _rail_right = train_right - 12;
var _rail_y = train_floor - 42;
var _rail_gap = 16;
draw_set_color(make_color_rgb(80, 88, 94));
draw_line_width(_rail_left, _rail_y, _rail_right, _rail_y, 2);
draw_line_width(_rail_left, _rail_y + _rail_gap, _rail_right, _rail_y + _rail_gap, 2);

var _wire_y = train_roof - 76;
var _roof_y = train_roof - 6;
var _middle_y = (_roof_y + _wire_y) * 0.5;

// Shared overhead wire.
draw_set_color(make_color_rgb(90, 96, 102));
draw_line_width(
    _draw_left, _wire_y,
    _draw_right, _wire_y,
    2
);

// Left, existing middle, and right collectors.
// Corner collectors sit slightly inward so they fit on the roof.
var _collector_positions = [
    train_left + 32,
    train_left + 284,
    train_right - 32
];

draw_set_color(make_color_rgb(150, 158, 166));

for (var _i = 0; _i < 3; _i++)
{
    var _collector_x = _collector_positions[_i];

    draw_line_width(
        _collector_x, _roof_y,
        _collector_x - 28, _middle_y,
        3
    );

    draw_line_width(
        _collector_x - 28, _middle_y,
        _collector_x, _wire_y,
        3
    );

    draw_line_width(
        _collector_x, _wire_y,
        _collector_x + 28, _middle_y,
        3
    );

    draw_line_width(
        _collector_x + 28, _middle_y,
        _collector_x, _roof_y,
        3
    );

    // Contact strip.
    draw_line_width(
        _collector_x - 20, _wire_y,
        _collector_x + 20, _wire_y,
        3
    );

    // Roof mounting plate.
    draw_rectangle(
        _collector_x - 18, _roof_y,
        _collector_x + 18, _roof_y + 6,
        false
    );
}
draw_set_color(_old_color);
draw_set_alpha(_old_alpha);
