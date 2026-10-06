var _gw = display_get_gui_width();

var _status = "TRANSIT — NEXT STOP: DEMO EXIT";

if (arrived)
{
    _status = "ARRIVED — EXIT OPEN";
}
else if (ride_elapsed >= cruise_duration)
{
    _status = "ARRIVING — PLEASE STAND CLEAR OF THE EXIT";
}

draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_center);

draw_text(
    _gw * 0.5,
    32,
    _status
);

draw_set_halign(fa_left);