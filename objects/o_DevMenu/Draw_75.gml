if (!enabled) exit;
var _color = draw_get_color();
var _alpha = draw_get_alpha();
var _font = draw_get_font();
var _halign = draw_get_halign();
var _valign = draw_get_valign();
draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

if (opened)
{
    draw_set_color(c_white);
    if (surface_exists(paused_surface)) draw_surface_stretched(paused_surface, 0, 0, _gw, _gh);
    draw_set_color(c_black);
    draw_set_alpha(0.65);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);
    var _height = row_count * row_height + 112;
    var _left = max(8, (_gw - panel_width) * 0.5);
    var _top = max(8, (_gh - _height) * 0.5);
    draw_set_color(make_color_rgb(20, 24, 32));
    draw_rectangle(_left, _top, _left + panel_width, _top + _height, false);
    draw_set_color(c_aqua);
    draw_text(_left + 16, _top + 12, "DEV MENU / PAUSED");
    draw_set_color(c_white);
    draw_text(_left + 16, _top + 36, "F1 / Esc close   |   Up / Down + Enter or click");
    var _rows = [
        "Collision overlay [F2]: " + (global.dev_collisions ? "ON" : "OFF"),
        "Invincibility: " + (global.dev_invincible ? "ON" : "OFF"),
        "Refill health and coins",
        "Equip pistol / reset attack cooldown",
        "Equip sword / reset attack cooldown",
        "Teleport to cursor position captured on opening",
        "Save current test position",
        "Teleport to saved position" + (is_undefined(test_position) ? " (none saved)" : ""),
        "Teleport to room spawn",
        "Restart current room",
        "Resume gameplay"
    ];
    for (var i = 0; i < row_count; ++i)
    {
        var _y = _top + 64 + i * row_height;
        if (i == selected)
        {
            draw_set_color(make_color_rgb(38, 65, 80));
            draw_rectangle(_left + 8, _y, _left + panel_width - 8, _y + row_height - 2, false);
        }
        draw_set_color(i == selected ? c_aqua : c_white);
        draw_text(_left + 16, _y + 5, _rows[i]);
    }
    draw_set_color(c_gray);
    draw_text(_left + 16, _top + _height - 30, "Actions resume play. Collision changes show on resume.");
}
else if (global.dev_invincible || global.dev_collisions)
{
    draw_set_color(c_black);
    draw_set_alpha(0.8);
    draw_rectangle(8, 8, 470, global.dev_collisions ? 70 : 34, false);
    draw_set_alpha(1);
    draw_set_color(c_aqua);
    draw_text(16, 14, "DEV [F1]" + (global.dev_invincible ? "   INVINCIBLE" : "") + (global.dev_collisions ? "   COLLISIONS [F2]" : ""));
    if (global.dev_collisions)
    {
        draw_set_color(c_white);
        draw_text(16, 34, "Boxes: cyan player / green terrain / red enemies");
        draw_text(16, 50, "yellow attacks / gray other. Fixtures: native colors.");
    }
}
draw_set_color(_color);
draw_set_alpha(_alpha);
draw_set_font(_font);
draw_set_halign(_halign);
draw_set_valign(_valign);
