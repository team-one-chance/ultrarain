// =====================================
// PLAYER HP BAR
// =====================================

var bar_x = 20;
var bar_y = 20;

var bar_width = 200;
var bar_height = 20;

var hp_percent = pHP / pHP_max;

// Keep value between 0 and 1
hp_percent = clamp(hp_percent, 0, 1);

// Background
draw_set_color(c_black);

draw_rectangle(
    bar_x,
    bar_y,
    bar_x + bar_width,
    bar_y + bar_height,
    false
);

// HP
draw_set_color(c_lime);

draw_rectangle(
    bar_x,
    bar_y,
    bar_x + (bar_width * hp_percent),
    bar_y + bar_height,
    false
);

// HP text
draw_set_color(c_white);

draw_text(
    bar_x,
    bar_y + bar_height + 5,
    string(pHP) + " / " + string(pHP_max)
);

// Reset
draw_set_color(c_white);