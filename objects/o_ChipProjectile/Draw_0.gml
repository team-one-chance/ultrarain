var _old_color = draw_get_color();
var _old_alpha = draw_get_alpha();
draw_set_alpha(1);
draw_set_color(is_healing ? c_lime : make_color_rgb(255, 80, 90));
draw_rectangle(x - 4, y - 4, x + 4, y + 4, false);
draw_set_color(c_white);
draw_rectangle(x - 2, y - 2, x + 2, y + 2, true);
draw_set_color(_old_color);
draw_set_alpha(_old_alpha);
