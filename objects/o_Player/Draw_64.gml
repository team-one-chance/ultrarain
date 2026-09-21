// HP bar
var bar_width = 200;
var bar_height = 20;

var bar_x = 20;
var bar_y = 20;

var hp_percent = pHP / pHP_max;

// Background
draw_set_color(c_black);
draw_rectangle(
    bar_x,
    bar_y,
    bar_x + bar_width,
    bar_y + bar_height,
    false
);

// Current HP
draw_set_color(c_lime);
draw_rectangle(
    bar_x,
    bar_y,
    bar_x + bar_width * hp_percent,
    bar_y + bar_height,
    false
);

