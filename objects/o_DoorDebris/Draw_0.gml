draw_set_color(debris_color);
draw_set_alpha(clamp(debris_life / 0.2, 0, 1));

draw_rectangle(
    floor(x), floor(y),
    floor(x) + debris_size - 1,
    floor(y) + debris_size - 1,
    false
);

draw_set_alpha(1);
draw_set_color(c_white);