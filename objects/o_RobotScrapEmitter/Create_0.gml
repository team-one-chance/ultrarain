image_speed = 0;
// Random points across the grinder width, at the marked height above it.
drop_min_y = 544;
drop_max_y = 545;
drop_interval = 1.5;
drop_timer = 0.1;
max_falling_bodies = 32;
ground_y = 2442; //2496
grinder_top_y = 848;
grinder_bottom_y = 944;
grinder_center_y = 896;
grinder_spans = [];
var _left = room_width;
var _right = 0;
var _gears = [o_GrinderLeft, o_GrinderRight];
for (var _type = 0; _type < array_length(_gears); _type++) {
    for (var _i = 0; _i < instance_number(_gears[_type]); _i++) {
        var _gear = instance_find(_gears[_type], _i);
        var _gear_left = _gear.x - sprite_get_xoffset(_gear.sprite_index);
        var _gear_top = _gear.y - sprite_get_yoffset(_gear.sprite_index);
        var _gear_right = _gear_left + _gear.sprite_width;
        var _gear_bottom = _gear_top + _gear.sprite_height;
        _left = min(_left, _gear_left);
        _right = max(_right, _gear_right);
        array_push(grinder_spans, {
            center_x: (_gear_left + _gear_right) * 0.5,
            top_y: _gear_top,
            bottom_y: _gear_bottom
        });
    }
}
if (array_length(grinder_spans) == 0) {
    _left = 4384;
    _right = 5152;
}
// Allow room for the whole robot and its slight horizontal drift at each edge.
drop_min_x = _left + 32;
drop_max_x = max(drop_min_x, _right - 32);

// A hatch calls this only after its shutters have opened.
release_robot = function(_spawn_x, _opening_y) {
    if (instance_number(o_FallingRobotScrap) >= max_falling_bodies) return noone;
    var _body = instance_create_depth(_spawn_x, _opening_y,
        depth - 1, o_FallingRobotScrap);
    _body.scrap_emitter = id;
    _body.scrap_release_y = _opening_y;
    _body.y = _opening_y - 24 * _body.scrap_size;
    _body.scrap_release_angle = _body.image_angle;
    _body.image_angle = 0;
    _body.scrap_emerged = false;
    var _best_distance = room_width;
    for (var _i = 0; _i < array_length(grinder_spans); _i++) {
        var _gear = grinder_spans[_i];
        var _distance = abs(_gear.center_x - _body.x);
        if (_distance < _best_distance) {
            _best_distance = _distance;
            _body.scrap_grinder_top = _gear.top_y;
            _body.scrap_grinder_bottom = _gear.bottom_y;
            _body.scrap_grinder_center = (_gear.top_y + _gear.bottom_y) * 0.5;
        }
    }
    return _body;
};
