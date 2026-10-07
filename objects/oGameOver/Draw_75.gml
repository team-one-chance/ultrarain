if (game_over_age < game_over_delay) exit;
update_layout();

var old_font = draw_get_font();
var old_colour = draw_get_color();
var old_alpha = draw_get_alpha();
var old_halign = draw_get_halign();
var old_valign = draw_get_valign();
var fade = clamp((game_over_age - game_over_delay) / 0.2, 0, 1);
var red = make_color_rgb(255, 55, 65);
var white = make_color_rgb(215, 225, 220);

// Industrial console panel over a dimmed view of the destroyed robot.
draw_set_color(c_black);
draw_set_alpha(0.65 * fade);
draw_rectangle(0, 0, gui_w, gui_h, false);
draw_set_alpha(fade);
draw_set_color(make_color_rgb(8, 11, 12));
draw_rectangle(panel_left, panel_top, panel_right, panel_bottom, false);
draw_set_color(red);
draw_rectangle(panel_left, panel_top, panel_right, panel_bottom, true);
draw_rectangle(panel_left, panel_top, panel_right, panel_top + 4 * ui_scale, false);

draw_set_font(f_Console);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_set_color(make_color_rgb(140, 155, 150));
draw_text_transformed(panel_left + 18 * ui_scale, panel_top + 25 * ui_scale,
    "ULTRARAIN // SYSTEM FAILURE", 0.55 * ui_scale, 0.55 * ui_scale, 0);
draw_line(panel_left + 18 * ui_scale, panel_top + 44 * ui_scale,
    panel_right - 18 * ui_scale, panel_top + 44 * ui_scale);

draw_set_halign(fa_center);
draw_set_color(red);
draw_text_transformed(centre_x, centre_y - 35 * ui_scale,
    "GAME OVER", 1.6 * ui_scale, 1.6 * ui_scale, 0);
draw_set_color(white);
draw_text_transformed(centre_x, centre_y + 8 * ui_scale,
    "[FATAL] ROBOT SIGNAL LOST", 0.6 * ui_scale, 0.6 * ui_scale, 0);

draw_set_color(button_hover ? red : make_color_rgb(25, 30, 32));
draw_rectangle(button_left, button_top, button_right, button_bottom, false);
draw_set_color(red);
draw_rectangle(button_left, button_top, button_right, button_bottom, true);
draw_set_color(button_hover ? c_black : white);
draw_text_transformed(centre_x, (button_top + button_bottom) * 0.5,
    "RESTART", 0.85 * ui_scale, 0.85 * ui_scale, 0);
draw_set_color(make_color_rgb(140, 155, 150));
draw_text_transformed(centre_x, panel_bottom - 14 * ui_scale,
    "CLICK RESTART / PRESS ENTER", 0.45 * ui_scale, 0.45 * ui_scale, 0);

draw_set_font(old_font);
draw_set_color(old_colour);
draw_set_alpha(old_alpha);
draw_set_halign(old_halign);
draw_set_valign(old_valign);
