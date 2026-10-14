line_x1 = 0;
line_y1 = 0;
line_x2 = 0;
line_y2 = 0;
line_color = c_yellow;
emissive = true; // Full brightness before bloom.

// Also called by o_Lighting after ambient dimming.
draw_emissive_streak = function()
{
    var _color = draw_get_color();
    var _alpha = draw_get_alpha();
    draw_set_alpha(1);
    draw_set_color(line_color);
    draw_line_width(line_x1, line_y1, line_x2, line_y2, 1);
    draw_set_color(_color);
    draw_set_alpha(_alpha);
};

// How long the line stays visible
life = 0.0005;