var _player = instance_find(o_Player, 0);
if (!instance_exists(_player)) exit;
// Don't put train instructions over the rest of the tutorial.
if (!ride_started && point_distance(_player.x, _player.y,
    camera_target_x, camera_target_y) > 900) exit;

var _status = "BOARD THE TRAIN TO DEPART";
if (arrived) _status = "ARRIVED — EXIT OPEN";
else if (ride_started && ride_elapsed >= cruise_duration)
    _status = "ARRIVING — PLEASE STAND CLEAR OF THE EXIT";
else if (ride_started) _status = "TRANSIT — NEXT STOP: DEMO EXIT";

var _old_color = draw_get_color();
var _old_alpha = draw_get_alpha();
var _old_h = draw_get_halign();
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_text(display_get_gui_width() * 0.5, 32, _status);
draw_set_halign(_old_h);
draw_set_color(_old_color);
draw_set_alpha(_old_alpha);
