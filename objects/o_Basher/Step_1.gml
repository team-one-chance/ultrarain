// Only the first Basher owns input; the sliders apply to every Basher.
if (id != instance_find(o_Basher, 0)) exit;
global.basher_tuner_capture_mouse = false;
if (!instance_exists(global.basher_tuner_target)) global.basher_tuner_target = id;
if (keyboard_check_pressed(vk_f6))
{
    global.basher_tuner_open = !global.basher_tuner_open;
    basher_tuner_drag = -1;
    if (!global.basher_tuner_open) basher_tuner_save(false);
}
if (keyboard_check_pressed(vk_f7))
{
    global.basher_tuner_open = true;
    basher_tuner_page = 1;
    if (global.basher_tuner_motion == 0) global.basher_tuner_motion = 1;
    basher_tuner_notice = "Walking preview on. Sliders change it live.";
}
if (!global.basher_tuner_open) exit;

var _layout = basher_tuner_layout();
var _mx = (device_mouse_x_to_gui(0) - _layout.left) / _layout.scale;
var _my = device_mouse_y_to_gui(0) / _layout.scale;
var _inside = _mx >= 0 && _mx <= 360 && _my >= 0 && _my <= 720;
global.basher_tuner_capture_mouse = _inside || basher_tuner_drag != -1;
var _pressed = mouse_check_button_pressed(mb_left);
var _held = mouse_check_button(mb_left);

if (_pressed && _inside)
{
    var _buttons = basher_tuner_buttons();
    for (var _i = 0; _i < array_length(_buttons); ++_i)
    {
        var _button = _buttons[_i];
        if (!point_in_rectangle(_mx, _my, _button.x, _button.y, _button.x + _button.w, _button.y + 28)) continue;
        switch (_button.kind)
        {
            case 0:
                basher_tuner_page = _button.value;
                if (basher_tuner_page == 1 && global.basher_tuner_motion == 0)
                {
                    global.basher_tuner_motion = 1;
                    basher_tuner_notice = "Walking preview on. Sliders change it live.";
                }
                break;
            case 1: global.basher_tuner_motion = _button.value; break;
            case 2: basher_tuner_save(true); break;
            case 3:
                for (var _j = 0; _j < array_length(basher_controls); ++_j)
                {
                    var _control = basher_controls[_j];
                    variable_struct_set(global.basher_tuning, _control.key, _control.value);
                }
                global.basher_tuning_revision++;
                basher_tuner_save(false);
                basher_tuner_notice = "Defaults restored.";
                break;
            case 4:
                var _count = instance_number(o_Basher);
                for (var _j = 0; _j < _count; ++_j)
                {
                    if (instance_find(o_Basher, _j) != global.basher_tuner_target) continue;
                    global.basher_tuner_target = instance_find(o_Basher, (_j + 1) mod _count);
                    break;
                }
                break;
            case 5:
                global.basher_tuning.body_wait_for_legs = 1 - round(global.basher_tuning.body_wait_for_legs);
                global.basher_tuning_revision++;
                basher_tuner_save(false);
                break;
        }
    }
    var _row = 0;
    for (var _i = 0; _i < array_length(basher_controls); ++_i)
    {
        var _control = basher_controls[_i];
        if (_control.page != basher_tuner_page) continue;
        if (variable_struct_exists(_control, "toggle") && _control.toggle) continue;
        var _top = (basher_tuner_page == 1) ? 282 + _row * 31 : 250 + _row * 35;
        if (point_in_rectangle(_mx, _my, 16, _top, 344, _top + (basher_tuner_page == 1 ? 30 : 32))) basher_tuner_drag = _i;
        _row++;
    }
}

if (basher_tuner_drag != -1)
{
    if (_held)
    {
        var _control = basher_controls[basher_tuner_drag];
        var _fraction = clamp((_mx - 18) / 324, 0, 1);
        var _value = clamp(round(lerp(_control.lo, _control.hi, _fraction) / _control.tick) * _control.tick, _control.lo, _control.hi);
        if (variable_struct_get(global.basher_tuning, _control.key) != _value)
        {
            variable_struct_set(global.basher_tuning, _control.key, _value);
            global.basher_tuning_revision++;
            basher_tuner_notice = "Changes are live. Release to save.";
        }
    }
    else
    {
        basher_tuner_drag = -1;
        basher_tuner_save(false);
    }
}
