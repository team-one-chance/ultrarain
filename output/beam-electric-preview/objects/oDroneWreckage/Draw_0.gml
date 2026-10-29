for (var _i = 0; _i < array_length(wreck_parts); _i++)
{
    var _part = wreck_parts[_i];
    var _ox = -_part.width * wreck_scale_x * 0.5;
    var _oy = -_part.height * wreck_scale_y * 0.5;
    var _draw_x = _part.px + _ox * dcos(_part.angle) + _oy * dsin(_part.angle);
    var _draw_y = _part.py - _ox * dsin(_part.angle) + _oy * dcos(_part.angle);
    draw_sprite_general(
        wreck_sprite, wreck_frame,
        _part.left, _part.top, _part.width, _part.height,
        _draw_x, _draw_y, wreck_scale_x, wreck_scale_y, _part.angle,
        wreck_tint, wreck_tint, wreck_tint, wreck_tint, 1
    );
}
