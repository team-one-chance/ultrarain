// Cosmetic wreckage stays in this room, with no fade timer or player collision.
if (!variable_instance_exists(id, "wreck_sprite")) wreck_sprite = sDrone;
if (!variable_instance_exists(id, "wreck_frame")) wreck_frame = 0;
if (!variable_instance_exists(id, "wreck_scale_x")) wreck_scale_x = 1;
if (!variable_instance_exists(id, "wreck_scale_y")) wreck_scale_y = 1;
if (!variable_instance_exists(id, "wreck_angle")) wreck_angle = 0;

wreck_parts = [];
wreck_gravity = 520;
if (!variable_instance_exists(id, "wreck_bounce_limit")) wreck_bounce_limit = 2;
wreck_tint = make_color_rgb(190, 190, 190);

wreck_blocked = function(_px, _py, _hw, _hh)
{
    // Enclose the rotated piece in whole pixels so collision rounding cannot
    // leave its visible edge slightly inside a floor or wall.
    var _left = floor(_px - _hw);
    var _top = floor(_py - _hh);
    var _right = ceil(_px + _hw);
    var _bottom = ceil(_py + _hh);
    if (collision_rectangle(_left, _top, _right, _bottom,
        [o_Block, o_Block_scary], false, true) != noone) return true;

    var _door = collision_rectangle(_left, _top, _right, _bottom,
        o_Door_UNB, false, true);
    if (instance_exists(_door) && _door.door_fixture != -1) return true;
    _door = collision_rectangle(_left, _top, _right, _bottom,
        o_Door_Breakable, false, true);
    return instance_exists(_door) && !_door.broken;
};

// Crop only metal/body sections of the approved drone, excluding both jets.
// Coordinates are relative to its 55 x 32 source canvas.
if (!variable_instance_exists(id, "wreck_source_width")) wreck_source_width = 55;
if (!variable_instance_exists(id, "wreck_source_height")) wreck_source_height = 32;
if (!variable_instance_exists(id, "wreck_cuts")) wreck_cuts = [
    [5, 9, 16, 3],
    [34, 9, 16, 3],
    [21, 9, 13, 3],
    [16, 12, 23, 10]
];
var _sw = sprite_get_width(wreck_sprite);
var _sh = sprite_get_height(wreck_sprite);
var _cos = dcos(wreck_angle);
var _sin = dsin(wreck_angle);
for (var _i = 0; _i < array_length(wreck_cuts); _i++)
{
    var _cut = wreck_cuts[_i];
    var _left = round(_cut[0] * _sw / wreck_source_width);
    var _top = round(_cut[1] * _sh / wreck_source_height);
    var _width = max(1, round(_cut[2] * _sw / wreck_source_width));
    var _height = max(1, round(_cut[3] * _sh / wreck_source_height));
    var _local_x = (array_length(_cut) > 4 ? _cut[4]
        : _left + _width * 0.5 - sprite_get_xoffset(wreck_sprite)) * wreck_scale_x;
    var _local_y = (array_length(_cut) > 5 ? _cut[5]
        : _top + _height * 0.5 - sprite_get_yoffset(wreck_sprite)) * wreck_scale_y;
    array_push(wreck_parts, {
        left: _left, top: _top, width: _width, height: _height,
        px: x + _local_x * _cos + _local_y * _sin,
        py: y - _local_x * _sin + _local_y * _cos,
        vx: sign(_local_x) * random_range(20, 45) + random_range(-12, 12),
        vy: random_range(-95, -40),
        angle: wreck_angle, spin: random_range(-180, 180),
        bounces: 0, resting: false
    });
}
