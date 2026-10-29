function draw_ik_arm(
    _upper_sprite,
    _lower_sprite,
    _shoulder_x,
    _shoulder_y,
    _target_x,
    _target_y,
    _upper_length,
    _lower_length,
    _bend_direction,
    _mirror
)
{
    var _dx = _target_x - _shoulder_x;
    var _dy = _target_y - _shoulder_y;

    var _real_distance = point_distance(
        _shoulder_x,
        _shoulder_y,
        _target_x,
        _target_y
    );

    _real_distance = max(_real_distance, 0.001);

    var _solve_distance = clamp(
        _real_distance,
        abs(_upper_length - _lower_length) + 0.001,
        _upper_length + _lower_length - 0.001
    );

    var _unit_x = _dx / _real_distance;
    var _unit_y = _dy / _real_distance;

    var _along =
        (
            sqr(_upper_length)
            - sqr(_lower_length)
            + sqr(_solve_distance)
        )
        / (2 * _solve_distance);

    var _height = sqrt(
        max(
            0,
            sqr(_upper_length) - sqr(_along)
        )
    );

    var _elbow_x =
        _shoulder_x
        + _unit_x * _along
        - _unit_y * _height * _bend_direction;

    var _elbow_y =
        _shoulder_y
        + _unit_y * _along
        + _unit_x * _height * _bend_direction;

    var _upper_angle = point_direction(
        _shoulder_x,
        _shoulder_y,
        _elbow_x,
        _elbow_y
    );

    var _lower_angle = point_direction(
        _elbow_x,
        _elbow_y,
        _target_x,
        _target_y
    );

    // +90 because the source sprites point downward.
    draw_sprite_ext(
        _upper_sprite,
        0,
        _shoulder_x,
        _shoulder_y,
        _mirror,
        1,
        _upper_angle + 90,
        c_white,
        1
    );

    draw_sprite_ext(
        _lower_sprite,
        0,
        _elbow_x,
        _elbow_y,
        _mirror,
        1,
        _lower_angle + 90,
        c_white,
        1
    );
}