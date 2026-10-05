draw_set_alpha(1);

// Black outline
draw_set_color(c_black);
draw_line_width(
    line_x1,
    line_y1,
    line_x2,
    line_y2,
    3
);

// Yellow center
draw_set_color(c_yellow);
draw_line_width(
    line_x1,
    line_y1,
    line_x2,
    line_y2,
    1
);

// Reset drawing settings
draw_set_alpha(1);
draw_set_color(c_white);