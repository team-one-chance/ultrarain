event_inherited();

if (drone_fire_state != 0 || drone_shot_flash_timer > 0)
{
    var _cx = (bbox_left + bbox_right) * 0.5;
    var _cy = (bbox_top + bbox_bottom) * 0.5;

    var _shot_flash = drone_shot_flash_timer > 0;

    var _progress = 1;

    if (drone_fire_state == 1)
    {
        _progress = clamp(
            1 - drone_charge_timer / drone_charge_duration,
            0, 1
        );
    }

    var _angle = drone_shot_angle;

    var _trace = drone_trace(
        _cx, _cy,
        _angle,
        drone_shot_range,
        false
    );

    // Faint aiming preview.
    draw_set_color(c_red);
    draw_set_alpha(0.35);

    if (drone_fire_state != 0)
    {
        draw_line_width(
            _cx, _cy,
            _trace.end_x, _trace.end_y,
            1
        );
    }

    // Match the hit shield's oval, leaving clearance even at the smallest size.
    var _ring_scale = _shot_flash ? 1.28 : 1.12 + _progress * 0.06;
    var _radius_x = sprite_get_width(sDrone_hit) * 0.5 * abs(image_xscale) * _ring_scale;
    var _radius_y = sprite_get_height(sDrone_hit) * 0.5 * abs(image_yscale) * _ring_scale;
    var _ring_x = _cx + attack_shake_x;
    var _ring_y = _cy + attack_shake_y;

    draw_set_color(
        _shot_flash
        ? make_color_rgb(255, 120, 35)
        : c_red
    );

    draw_set_alpha(_shot_flash ? 1 : 0.45);

    draw_ellipse(_ring_x - _radius_x, _ring_y - _radius_y,
        _ring_x + _radius_x, _ring_y + _radius_y, true);

    if (_shot_flash)
    {
        draw_ellipse(_ring_x - _radius_x + 2, _ring_y - _radius_y + 2,
            _ring_x + _radius_x - 2, _ring_y + _radius_y - 2, true);
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
}
