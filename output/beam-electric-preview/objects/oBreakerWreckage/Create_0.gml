// Use the drone's persistent, colliding wreckage with Breaker's own artwork.
if (!variable_instance_exists(id, "wreck_shield")) wreck_shield = false;
wreck_frame = 0;
wreck_angle = 0;
wreck_bounce_limit = 2;
if (wreck_shield) {
    wreck_sprite = s_Breaker_idle;
    wreck_source_width = 65;
    wreck_source_height = 90;
    // Only the shield at the right of the shielded idle canvas.
    wreck_cuts = [[50, 0, 15, 22], [50, 22, 15, 22],
        [50, 44, 15, 22], [50, 66, 15, 24]];
    x += (42 - 64) * wreck_scale_x;
    y += (118 - 208) * wreck_scale_y;
}
else {
    wreck_sprite = s_Breaker_idle_unshielded;
    wreck_source_width = 53;
    wreck_source_height = 80;
    // Head/shoulders, arms, torso, thighs and feet become separate pieces.
    wreck_cuts = [[0, 0, 53, 22], [0, 22, 18, 27],
        [18, 22, 21, 27], [39, 22, 14, 27],
        [0, 49, 26, 16], [26, 49, 27, 16],
        [0, 65, 26, 15], [26, 65, 27, 15]];
    x += (42 - 64) * wreck_scale_x;
    y += (128 - 208) * wreck_scale_y;
}
event_inherited();

for (var _i = array_length(wreck_parts) - 1; _i >= 0; _i--) {
    var _part = wreck_parts[_i];
    _part.vx = random_range(-90, 90);
    _part.vy = random_range(-180, -85);
    _part.spin = choose(-1, 1) * random_range(100, 260);
    // Lift cropped feet/shield tips clear of the floor before launching.
    var _hw = _part.width * abs(wreck_scale_x) * 0.5;
    var _hh = _part.height * abs(wreck_scale_y) * 0.5;
    var _spawn_y = _part.py;
    var _escape = ceil((_hw + _hh) * 2) + 2;
    var _clear = false;
    for (var _lift = 0; _lift <= _escape; _lift++) {
        if (wreck_blocked(_part.px, _spawn_y - _lift, _hw + 1, _hh + 1)) continue;
        _part.py = _spawn_y - _lift;
        _clear = true;
        break;
    }
    if (!_clear) array_delete(wreck_parts, _i, 1);
}
