if (!training_active()) { draw_self(); exit; }
var _color = draw_get_color();
var _alpha = draw_get_alpha();
draw_set_alpha(1);
draw_set_color(make_color_rgb(5, 35, 45));
draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, false);
draw_set_color(c_aqua);
draw_rectangle(bbox_left + 1, bbox_top + 1, bbox_right - 1, bbox_bottom - 1, true);
draw_line_width(bbox_left + 5, bbox_top + 8, bbox_right - 5, bbox_bottom - 8, 2);
draw_line_width(bbox_left + 5, bbox_bottom - 8, bbox_right - 5, bbox_top + 8, 2);
draw_set_color(_color);
draw_set_alpha(_alpha);
