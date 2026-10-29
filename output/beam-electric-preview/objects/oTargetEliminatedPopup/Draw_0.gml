var old_font = draw_get_font();
var old_colour = draw_get_color();
var old_alpha = draw_get_alpha();
var old_halign = draw_get_halign();
var old_valign = draw_get_valign();

draw_set_font(f_Console);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

var opacity = clamp((popup_duration - popup_age) / 0.35, 0, 1);
var half_width = string_width(popup_text) * popup_scale * 0.5 + 5;
var half_height = string_height(popup_text) * popup_scale * 0.5 + 3;

// Dark backing keeps the red text legible against bright scenery.
draw_set_alpha(opacity * 0.85);
draw_set_color(make_color_rgb(12, 12, 18));
draw_roundrect(x - half_width, y - half_height,
    x + half_width, y + half_height, false);

// A black outline preserves contrast around each letter.
draw_set_alpha(opacity);
draw_set_color(c_black);
for (var ox = -1; ox <= 1; ox++)
{
    for (var oy = -1; oy <= 1; oy++)
    {
        if (ox == 0 && oy == 0) continue;
        draw_text_transformed(x + ox, y + oy, popup_text,
            popup_scale, popup_scale, 0);
    }
}
draw_set_color(popup_colour);
draw_text_transformed(x, y, popup_text, popup_scale, popup_scale, 0);

draw_set_font(old_font);
draw_set_color(old_colour);
draw_set_alpha(old_alpha);
draw_set_halign(old_halign);
draw_set_valign(old_valign);
