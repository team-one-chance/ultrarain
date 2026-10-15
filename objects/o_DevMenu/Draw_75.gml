if (!enabled) exit;
var _color = draw_get_color();
var _alpha = draw_get_alpha();
var _font = draw_get_font();
var _halign = draw_get_halign();
var _valign = draw_get_valign();
var _filter = gpu_get_texfilter();
draw_set_font(f_Console);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

// Reuse the last simulation image for menu pause, time pause, and skipped ticks.
if (world_frozen && surface_exists(paused_surface))
{
    draw_set_color(c_white);
    draw_surface_stretched(paused_surface, 0, 0, _gw, _gh);
}

if (opened)
{
    draw_set_color(c_black);
    draw_set_alpha(0.65);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);
    var _layout = menu_layout();
    var _scale = _layout.scale;
    var _text_scale = _scale * 0.72;
    var _left = _layout.left;
    var _top = _layout.top;
    draw_set_color(make_color_rgb(20, 24, 32));
    draw_rectangle(_left, _top, _left + _layout.width, _top + _layout.height, false);
    // Filter the antialiased console font locally, preserving pixel-art settings.
    gpu_set_texfilter(true);
    draw_set_color(c_aqua);
    var _titles = ["CATEGORIES", "PLAYER", "WORLD", "ENEMIES", "TIME", "DEBUG"];
    draw_text_transformed(_left + 16 * _scale, _top + 12 * _scale,
        "DEV MENU / " + _titles[page], _text_scale, _text_scale, 0);
    draw_set_color(c_white);
    draw_text_transformed(_left + 16 * _scale, _top + 40 * _scale,
        "F1 close | Esc back | Up/Down + Enter or click", _text_scale, _text_scale, 0);
    draw_set_color(c_gray);
    draw_text_transformed(_left + 16 * _scale, _top + 64 * _scale,
        "Game: " + (time_paused ? "PAUSED" : string(round(time_rate * 100)) + "% speed")
        + " | Enemy AI: " + (global.dev_freeze_enemies ? "FROZEN" : "ACTIVE"),
        _text_scale * 0.85, _text_scale * 0.85, 0);
    var _actions = menu_actions();
    for (var i = 0; i < array_length(_actions); ++i)
    {
        var _y = _top + (88 + i * row_height) * _scale;
        if (i == selected)
        {
            draw_set_color(make_color_rgb(38, 65, 80));
            draw_rectangle(_left + 8 * _scale, _y, _left + _layout.width - 8 * _scale,
                _y + (row_height - 2) * _scale, false);
        }
        draw_set_color(i == selected ? c_aqua : c_white);
        draw_text_transformed(_left + 16 * _scale, _y + 4 * _scale, menu_label(_actions[i]),
            _text_scale, _text_scale, 0);
    }
    draw_set_color(c_gray);
    draw_text_transformed(_left + 16 * _scale, _top + _layout.height - 28 * _scale,
        "F2 collisions | F4 pause/resume | F5 single frame",
        _text_scale * 0.85, _text_scale * 0.85, 0);
}
else if (global.dev_freecam || global.dev_invincible || global.dev_collisions || global.dev_freeze_enemies || time_paused || time_rate != 1)
{
    var _status = "DEV [F1]"
        + (time_paused ? " | PAUSED [F4] / STEP [F5]" : (time_rate != 1 ? " | " + string(round(time_rate * 100)) + "% SPEED" : ""))
        + (global.dev_invincible ? " | INVINCIBLE" : "")
        + (global.dev_freeze_enemies ? " | AI FROZEN" : "")
        + (global.dev_collisions ? " | COLLISIONS" : "")
        + (global.dev_freecam ? " | FREECAM [F6] / WASD / SHIFT" : "");
    draw_set_color(c_black);
    draw_set_alpha(0.8);
    draw_rectangle(8, 8, min(_gw - 8, string_width(_status) * 0.65 + 32), global.dev_collisions ? 78 : 36, false);
    draw_set_alpha(1);
    gpu_set_texfilter(true);
    draw_set_color(c_aqua);
    draw_text_transformed(16, 12, _status, 0.65, 0.65, 0);
    if (global.dev_collisions)
    {
        draw_set_color(c_white);
        draw_text_transformed(16, 34, "Boxes: cyan player / green terrain / red enemies", 0.65, 0.65, 0);
        draw_text_transformed(16, 54, "Yellow attacks / gray other. Fixtures: native colors.", 0.65, 0.65, 0);
    }
}
gpu_set_texfilter(_filter);
draw_set_color(_color);
draw_set_alpha(_alpha);
draw_set_font(_font);
draw_set_halign(_halign);
draw_set_valign(_valign);
