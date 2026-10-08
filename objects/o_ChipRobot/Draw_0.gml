var _old_color = draw_get_color();
var _old_alpha = draw_get_alpha();
draw_set_alpha(1);
var _stunned = chip_state == ChipRobotState.STUN || slam_stun_timer > 0;
var _body = _stunned ? make_color_rgb(80, 85, 90) : make_color_rgb(145, 155, 165);
if (hit_timer > 0) _body = c_white;
draw_set_color(_body);
draw_rectangle(x - 23, y - 31, x + 23, y - 5, false);
draw_set_color(c_black);
draw_rectangle(x - 18, y - 25, x + 18, y - 13, false);
draw_set_color(_stunned ? c_red : c_white);
draw_rectangle(x + chip_facing * 10 - 3, y - 23,
    x + chip_facing * 10 + 3, y - 19, false);
draw_set_color(make_color_rgb(85, 95, 105));
draw_rectangle(x - 18, y - 5, x - 6, y, false);
draw_rectangle(x + 6, y - 5, x + 18, y, false);

var _extended = chip_state == ChipRobotState.WINDUP
    || chip_state == ChipRobotState.DASH || chip_state == ChipRobotState.THROW;
var _arm_x = x + chip_facing * (_extended ? 36 : 24);
draw_set_color(c_white);
draw_line_width(x + chip_facing * 16, y - 16, _arm_x, y - 20, 3);
if (chip_has_chip)
{
    var _support = chip_state == ChipRobotState.THROW && chip_throw_is_healing;
    draw_set_color(_support ? c_lime : make_color_rgb(255, 80, 90));
    draw_rectangle(_arm_x - 4, y - 24, _arm_x + 4, y - 16, false);
}
if (chip_state == ChipRobotState.WINDUP)
{
    draw_set_alpha(0.25);
    draw_set_color(c_red);
    draw_line_width(x, y - 16, x + chip_dash_direction * 180, y - 16, 2);
    draw_set_alpha(1);
}
if (chip_state == ChipRobotState.REBUILD)
{
    draw_set_color(c_lime);
    draw_line_width(x - 20, y - 38,
        x - 20 + 40 * (1 - chip_state_timer / chip_rebuild_duration), y - 38, 3);
}
draw_set_color(c_black);
draw_rectangle(x - 22, y - 45, x + 22, y - 40, false);
draw_set_color(c_red);
draw_rectangle(x - 21, y - 44, x - 21 + 42 * clamp(ehp / ehp_max, 0, 1), y - 41, false);
draw_set_color(_old_color);
draw_set_alpha(_old_alpha);
