if (id != instance_find(o_Basher, 0) || !global.basher_tuner_open) exit;
var _layout = basher_tuner_layout();
var _s = _layout.scale;
var _left = _layout.left;
var _font = draw_get_font();
var _colour = draw_get_color();
var _alpha = draw_get_alpha();
var _halign = draw_get_halign();
var _valign = draw_get_valign();
var _filter = gpu_get_texfilter();
draw_set_font(f_Console);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
draw_set_color(make_color_rgb(20, 25, 34));
draw_rectangle(_left, 0, display_get_gui_width(), display_get_gui_height(), false);
draw_set_color(make_color_rgb(78, 201, 209));
draw_rectangle(_left, 0, _left + 2 * _s, display_get_gui_height(), false);
gpu_set_texfilter(true);
draw_text_transformed(_left + 14 * _s, 10 * _s, "BASHER / LIVE TUNER", _s * 0.85, _s * 0.85, 0);
draw_set_color(c_ltgray);
draw_text_transformed(_left + 14 * _s, 40 * _s, "F6 panel / F7 movement", _s * 0.65, _s * 0.65, 0);

draw_set_color(make_color_rgb(34, 41, 52));
draw_rectangle(_left + 12 * _s, 70 * _s, _left + 346 * _s, 198 * _s, false);
var _target = global.basher_tuner_target;
var _unreachable = false;
if (instance_exists(_target))
{
    // The same rig as the room, fitted inside the preview without moving it.
    var _cfg = _target.basher_config;
    var _minx = 0;
    var _maxx = 73 * _cfg.body_scale;
    var _miny = 0;
    var _maxy = _cfg.standing_height;
    for (var _i = 0; _i < 4; ++_i)
    {
        var _hip = _cfg.legs[_i].hip;
        _minx = min(_minx, _hip[0] - _cfg.upper_length - 8 * _cfg.leg_scale);
        _maxx = max(_maxx, _hip[0] + _cfg.upper_length + 8 * _cfg.leg_scale);
        _miny = min(_miny, _hip[1] - _cfg.upper_length - 8 * _cfg.leg_scale);
        if (!_target.basher_ready) continue;
        var _leg = _target.basher_legs[_i];
        var _fx = _leg.foot_x - _target.x;
        var _fy = _leg.foot_y - _target.y;
        _minx = min(_minx, _fx - 18 * _cfg.foot_scale);
        _maxx = max(_maxx, _fx + 18 * _cfg.foot_scale);
        _maxy = max(_maxy, _fy + _cfg.foot_sole);
        var _distance = point_distance(_hip[0], _hip[1], _fx, _fy);
        if (_distance >= _cfg.upper_length + _cfg.lower_length || _distance <= abs(_cfg.upper_length - _cfg.lower_length)) _unreachable = true;
    }
    var _zoom = min(2.5, min(310 / max(1, _maxx - _minx), 90 / max(1, _maxy - _miny)));
    var _matrix = matrix_get(matrix_world);
    matrix_set(matrix_world, matrix_build(
        _left + 180 * _s - (_target.x + (_minx + _maxx) * 0.5) * _zoom * _s,
        125 * _s - (_target.y + (_miny + _maxy) * 0.5) * _zoom * _s,
        0, 0, 0, 0, _zoom * _s, _zoom * _s, 1));
    gpu_set_texfilter(false);
    _target.basher_draw_rig();
    matrix_set(matrix_world, _matrix);
    gpu_set_texfilter(true);
    draw_set_color(c_gray);
    draw_text_transformed(_left + 20 * _s, 177 * _s,
        "Preview x" + string_format(_zoom, 0, 2) + " / " + string(instance_number(o_Basher)) + " Basher(s)", _s * 0.55, _s * 0.55, 0);
}

var _buttons = basher_tuner_buttons();
for (var _i = 0; _i < array_length(_buttons); ++_i)
{
    var _button = _buttons[_i];
    var _selected = (_button.kind == 0 && basher_tuner_page == _button.value)
        || (_button.kind == 1 && global.basher_tuner_motion == _button.value)
        || (_button.kind == 5 && global.basher_tuning.body_wait_for_legs >= 0.5);
    draw_set_color(_selected ? make_color_rgb(39, 91, 103) : make_color_rgb(47, 55, 69));
    draw_rectangle(_left + _button.x * _s, _button.y * _s,
        _left + (_button.x + _button.w) * _s, (_button.y + 28) * _s, false);
    draw_set_color(_selected ? c_aqua : c_white);
    draw_set_halign(fa_center);
    draw_text_transformed(_left + (_button.x + _button.w * 0.5) * _s, (_button.y + 5) * _s,
        _button.label, _s * 0.62, _s * 0.62, 0);
    draw_set_halign(fa_left);
}

var _row = 0;
for (var _i = 0; _i < array_length(basher_controls); ++_i)
{
    var _control = basher_controls[_i];
    if (_control.page != basher_tuner_page) continue;
    if (variable_struct_exists(_control, "toggle") && _control.toggle) continue;
    var _top = (basher_tuner_page == 1) ? 282 + _row * 31 : 250 + _row * 35;
    var _value = variable_struct_get(global.basher_tuning, _control.key);
    var _fraction = clamp((_value - _control.lo) / (_control.hi - _control.lo), 0, 1);
    draw_set_color(c_white);
    draw_text_transformed(_left + 16 * _s, _top * _s, _control.label, _s * 0.65, _s * 0.65, 0);
    draw_set_halign(fa_right);
    draw_set_color(c_aqua);
    draw_text_transformed(_left + 344 * _s, _top * _s, string_format(_value, 0, 2), _s * 0.65, _s * 0.65, 0);
    draw_set_halign(fa_left);
    draw_set_color(make_color_rgb(62, 72, 88));
    draw_rectangle(_left + 18 * _s, (_top + 23) * _s, _left + 342 * _s, (_top + 27) * _s, false);
    draw_set_color(c_aqua);
    draw_rectangle(_left + 18 * _s, (_top + 23) * _s, _left + (18 + 324 * _fraction) * _s, (_top + 27) * _s, false);
    draw_circle(_left + (18 + 324 * _fraction) * _s, (_top + 25) * _s, 4 * _s, false);
    _row++;
}
draw_set_color(_unreachable ? c_orange : c_ltgray);
draw_text_transformed(_left + 14 * _s, 695 * _s,
    _unreachable ? (global.basher_tuning.body_wait_for_legs >= 0.5 ? "Reach limit: adjust lengths / height." : "Feet catching up; body keeps moving.") : basher_tuner_notice, _s * 0.55, _s * 0.55, 0);
gpu_set_texfilter(_filter);
draw_set_font(_font);
draw_set_halign(_halign);
draw_set_valign(_valign);
draw_set_color(_colour);
draw_set_alpha(_alpha);
