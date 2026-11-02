var _dt = (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) / 1000000;
if (bounce_travel)
{
    bounce_elapsed += _dt;
    var _distance = point_distance(bounce_origin_x, bounce_origin_y,
        bounce_target_x, bounce_target_y);
    if (_distance <= 0) { instance_destroy(); exit; }
    var _travel = min(_distance, bounce_elapsed * bounce_speed);
    var _tail_start = max(0, _travel - bounce_tail_length);
    line_x1 = lerp(bounce_origin_x, bounce_target_x, _tail_start / _distance);
    line_y1 = lerp(bounce_origin_y, bounce_target_y, _tail_start / _distance);
    line_x2 = lerp(bounce_origin_x, bounce_target_x, _travel / _distance);
    line_y2 = lerp(bounce_origin_y, bounce_target_y, _travel / _distance);
    if (bounce_elapsed >= _distance / bounce_speed + 0.03) instance_destroy();
    exit;
}
life -= _dt;

if (life <= 0)
{
    instance_destroy();
}
