event_inherited();

if (drone_fire_state != 0)
{
    var _cx = (bbox_left + bbox_right) * 0.5;
    var _cy = (bbox_top + bbox_bottom) * 0.5;

    var _firing_warning =
        drone_fire_state == 2
        || drone_charge_timer <= 0.2;

    var _locked =
        drone_fire_state == 2
        || drone_charge_timer <= drone_aim_lock_duration;

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
    draw_set_alpha(0.25);

    draw_line_width(
        _cx, _cy,
        _trace.end_x, _trace.end_y,
        1
    );

    // Larger orange ring during the final warning and entire burst.
    var _radius = _firing_warning
        ? 30
        : 18 + _progress * 5;

    draw_set_color(
        _firing_warning
        ? make_color_rgb(255, 120, 35)
        : c_red
    );

    draw_set_alpha(_firing_warning ? 0.9 : 0.45);

    draw_circle(_cx, _cy, _radius, true);

    if (_firing_warning)
    {
        draw_circle(_cx, _cy, _radius - 2, true);
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
}