if ((!enabled || menu_exhibition_active()) && !(instance_exists(o_PauseMenu) && o_PauseMenu.opened)) exit;
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
    // Keep the frozen image proportional while the aspect setting changes behind the pause panel.
    var _paused_scale = min(_gw / surface_get_width(paused_surface), _gh / surface_get_height(paused_surface));
    var _paused_width = surface_get_width(paused_surface) * _paused_scale;
    var _paused_height = surface_get_height(paused_surface) * _paused_scale;
    draw_surface_stretched(paused_surface, (_gw - _paused_width) * 0.5, (_gh - _paused_height) * 0.5,
        _paused_width, _paused_height);
}

if (opened && map_open)
{
    draw_set_color(make_color_rgb(12, 16, 22));
    draw_rectangle(0, 0, _gw, _gh, false);
    var _layout = map_layout();
    var _ox = _layout.x - map_center_x * _layout.scale;
    var _oy = _layout.y - map_center_y * _layout.scale;
    map_bake_cache();
    draw_set_color(make_color_rgb(30, 36, 44));
    draw_rectangle(_ox, _oy, _ox + room_width * _layout.scale, _oy + room_height * _layout.scale, false);
    if (map_cache_ready && surface_exists(map_cache_surface))
    {
        draw_set_color(c_white);
        draw_surface_ext(map_cache_surface,
            _ox + map_bounds[0] * _layout.scale, _oy + map_bounds[1] * _layout.scale,
            _layout.scale / map_cache_scale, _layout.scale / map_cache_scale, 0, c_white, 1);
    }
    draw_set_color(c_gray);
    draw_rectangle(_ox, _oy, _ox + room_width * _layout.scale, _oy + room_height * _layout.scale, true);
    if (!is_undefined(map_player))
    {
        var _px = _ox + map_player[0] * _layout.scale;
        var _py = _oy + map_player[1] * _layout.scale;
        draw_set_color(c_black);
        draw_circle(_px, _py, 7, false);
        draw_set_color(c_aqua);
        draw_circle(_px, _py, 5, false);
    }
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _tx = (_mx - _ox) / _layout.scale;
    var _ty = (_my - _oy) / _layout.scale;
    var _valid = _tx >= 0 && _tx < room_width && _ty >= 0 && _ty < room_height;
    draw_set_color(_valid ? c_aqua : c_gray);
    draw_line(_mx - 8, _my, _mx + 8, _my);
    draw_line(_mx, _my - 8, _mx, _my + 8);
    draw_set_color(make_color_rgb(20, 24, 32));
    draw_rectangle(0, 0, _gw, 80, false);
    draw_rectangle(0, _gh - 32, _gw, _gh, false);
    gpu_set_texfilter(true);
    var _ts = min(0.65, _gw / 1100);
    draw_set_color(c_aqua);
    draw_text_transformed(16, 10, "TELEPORT MAP / " + room_get_name(room), _ts, _ts, 0);
    draw_set_color(c_white);
    draw_text_transformed(16, 36, "Scroll zoom | Middle drag | Home fit | R rebuild | Esc back | F1 close", _ts, _ts, 0);
    var _map_status = "Preparing map... (Esc to cancel)";
    if (map_cache_ready)
    {
        if (is_undefined(map_player)) _map_status = "No player in this room";
        else _map_status = "Click to teleport | " + string(floor(_tx)) + ", " + string(floor(_ty))
            + " | Zoom " + string(round(map_zoom * 100)) + "%";
    }
    draw_text_transformed(16, _gh - 28, _map_status, _ts, _ts, 0);
}
else if (opened)
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
