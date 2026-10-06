draw_set_alpha(1);

draw_set_color(c_dkgray);
draw_rectangle(x - 12, y - 9, x + 12, y + 9, false);

draw_set_color(c_lime);
draw_rectangle(x - 12, y - 9, x + 12, y + 9, true);

// Green cross.
draw_rectangle(x - 2, y - 6, x + 2, y + 6, false);
draw_rectangle(x - 6, y - 2, x + 6, y + 2, false);

draw_set_color(c_white);