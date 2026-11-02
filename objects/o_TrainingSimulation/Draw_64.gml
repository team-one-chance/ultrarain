var _width = display_get_gui_width();
var _height = display_get_gui_height();
var _old_font = draw_get_font();
var _old_color = draw_get_color();
var _old_alpha = draw_get_alpha();
var _old_halign = draw_get_halign();
var _old_valign = draw_get_valign();
var _ui_scale = clamp(min(_width / 1440, _height / 720), 0.65, 1.5); // GUI adaptation; preserves legibility at 720p through 1080p.
var _text_scale = ui_text_scale * _ui_scale;
var _panel_left = max(230, _width * 0.12); // GUI pixels; keeps the enlarged panel clear of the health HUD.
var _content_width = max(160, _width - _panel_left * 2 - 32);
var _panel_bottom = 160 * _ui_scale;
draw_set_font(-1);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_alpha(0.9);
draw_set_color(c_black);
draw_rectangle(_panel_left, 12 * _ui_scale, _width - _panel_left, _panel_bottom, false);
draw_set_alpha(clamp(text_age / 0.12, 0, 1));
draw_set_color(c_aqua);
draw_text_transformed(_width / 2, 22 * _ui_scale, "SIMULATION // " + string(section + 1) + "/10",
    1.25 * _ui_scale, 1.25 * _ui_scale, 0);
draw_set_color(c_white);
draw_text_ext_transformed(_width / 2, 50 * _ui_scale,
    string_copy(objective, 1, ceil(text_age * 160)), 18, _content_width / _text_scale,
    _text_scale, _text_scale, 0);
if (prompt != "") input_prompt_draw(input_prompt_definition(prompt),
    input_prompt_definition(prompt).text, _width / 2, _height - 64 * _ui_scale,
    prompt, ui_prompt_scale * _ui_scale);
if (section == 7 && stage >= 1)
{
    draw_set_alpha(1);
    draw_set_halign(fa_center);
    draw_text_transformed(_width / 2, _panel_bottom - 28 * _ui_scale,
        string(coin_hits) + " / 3 COINS HIT", 1.25 * _ui_scale, 1.25 * _ui_scale, 0);
}
if (section == 3 && !demonstrated("wall"))
{
    var _half_bar = 100 * _ui_scale;
    var _bar_y = _panel_bottom - 16 * _ui_scale;
    draw_set_alpha(1);
    draw_set_color(c_dkgray);
    draw_rectangle(_width / 2 - _half_bar, _bar_y, _width / 2 + _half_bar, _bar_y + 5 * _ui_scale, false);
    draw_set_color(c_aqua);
    draw_rectangle(_width / 2 - _half_bar, _bar_y,
        _width / 2 - _half_bar + _half_bar * 2 * clamp(wall_hold_time / wall_hold_required, 0, 1),
        _bar_y + 5 * _ui_scale, false);
}
if (transition_time > 0)
{
    draw_set_color(c_aqua);
    draw_set_alpha(transition_time / 0.13 * 0.22);
    draw_rectangle(0, 0, _width, _height, false);
    for (var _line = 0; _line < _height; _line += 12)
        draw_rectangle(0, _line, _width, _line + 2, false);
}
if (ending_time >= 0)
{
    draw_set_halign(fa_right);
    draw_set_color(make_color_rgb(255, 70, 80));
    draw_set_alpha(1);
    var _rows = floor(ending_time * 32);
    for (var _i = 0; _i < _rows; ++_i)
        draw_text(_width - 16 - (_i div 25) * 210, 20 + (_i mod 25) * 18,
            "ERROR // SUBJECT DISCONNECTED");
}
if (debug_visible && instance_exists(o_Player))
{
    var _remaining = 0;
    for (var _i = 0; _i < array_length(targets); ++_i) if (!targets[_i].defeated) _remaining++;
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_black);
    draw_set_alpha(0.9);
    draw_rectangle(12, _panel_bottom + 16, 760, _panel_bottom + 220, false);
    draw_set_alpha(1);
    draw_set_color(c_aqua);
    draw_text(20, _panel_bottom + 24, "TRAINING F4 // section=" + string(section + 1) + " stage=" + string(stage)
        + " generation=" + string(generation)
        + "\nobjective=" + objective
        + "\nweapons: pistol=" + string(o_Player.owns_pistol) + " sword=" + string(o_Player.owns_sword)
        + " selected=" + o_Player.weapon_type
        + "\nunlocked: movement=" + string(training_action_allowed("left"))
        + " dash/slide=" + string(training_action_allowed("dash"))
        + " wall/slam=" + string(training_action_allowed("slam"))
        + " coins=" + string(training_action_allowed("coin"))
        + "\nwall hold=" + string_format(wall_hold_time, 0, 2) + "/" + string(wall_hold_required)
        + " gate=" + string(instance_exists(wall_gate)) + " geometry=" + string(array_length(section_geometry))
        + "\nactions=" + json_stringify(actions) + " direct coins=" + string(coin_hits) + "/3"
        + "\nactive targets=" + string(_remaining) + " reset=" + string(reset_pending)
        + " transition=" + string(transition_time) + " ending=" + string(ending_time));
}
draw_set_font(_old_font);
draw_set_color(_old_color);
draw_set_alpha(_old_alpha);
draw_set_halign(_old_halign);
draw_set_valign(_old_valign);
