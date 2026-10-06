draw_set_alpha(1);

// Tunnel background.
var _left = 0;
var _right = room_width;
var _top = 0;
var _bottom = room_height;

var _cam = view_camera[0];
var _view_x = camera_get_view_x(_cam);
var _view_y = camera_get_view_y(_cam);
var _view_w = camera_get_view_width(_cam);
var _view_h = camera_get_view_height(_cam);

draw_set_color(c_black);
draw_rectangle(
    _view_x, _view_y,
    _view_x + _view_w, _view_y + _view_h,
    false
);

// Passing tunnel pillars across the entire camera view.
var _spacing = 160;
var _offset = scenery_distance mod _spacing;

// Keep the pattern anchored in room coordinates.
var _first_pillar =
    floor((_view_x + _offset) / _spacing) * _spacing
    - _offset
    - _spacing;

draw_set_color(make_color_rgb(30, 35, 40));
draw_set_alpha(0.45);

for (
    var _pillar = _first_pillar;
    _pillar < _view_x + _view_w + _spacing;
    _pillar += _spacing
)
{
    draw_rectangle(
        _pillar, _view_y,
        _pillar + 24, _view_y + _view_h,
        false
    );
}

// Rail endpoints are independent of the background size.
draw_set_alpha(1);
var _rail_left = 100;
var _rail_right = 660;

draw_set_color(make_color_rgb(80, 88, 94));
var _rail_y = 470;
var _rail_gap = 16;

draw_line_width(
    _rail_left, _rail_y,
    _rail_right, _rail_y,
    2
);

draw_line_width(
    _rail_left, _rail_y + _rail_gap,
    _rail_right, _rail_y + _rail_gap,
    2
);

// Overhead power wire.
var _wire_y = 180;
var _roof_y = 250;
var _collector_x = 380;

draw_set_alpha(1);
draw_set_color(make_color_rgb(90, 96, 102));

draw_line_width(
    _view_x, _wire_y,
    _view_x + _view_w, _wire_y,
    2
);

// Diamond-shaped current collector above the roof.
draw_set_color(make_color_rgb(150, 158, 166));

draw_line_width(
    _collector_x, _roof_y,
    _collector_x - 28, (_roof_y + _wire_y) * 0.5,
    3
);

draw_line_width(
    _collector_x - 28, (_roof_y + _wire_y) * 0.5,
    _collector_x, _wire_y,
    3
);

draw_line_width(
    _collector_x, _wire_y,
    _collector_x + 28, (_roof_y + _wire_y) * 0.5,
    3
);

draw_line_width(
    _collector_x + 28, (_roof_y + _wire_y) * 0.5,
    _collector_x, _roof_y,
    3
);

// Contact strip and roof mounting plate.
draw_line_width(
    _collector_x - 20, _wire_y,
    _collector_x + 20, _wire_y,
    3
);

draw_rectangle(
    _collector_x - 18, _roof_y,
    _collector_x + 18, _roof_y + 6,
    false
);

draw_set_color(c_white);
draw_set_alpha(1);	