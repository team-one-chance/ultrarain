// Draw the enemy normally
draw_self();

// HP bar settings
var bar_width = 40;
var bar_height = 5;

// Position above enemy
var bar_x = x - bar_width / 2;
var bar_y = y - sprite_height / 2 - 8;

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
var hp_percent = ehp / ehp_max;

draw_set_color(c_red);
draw_rectangle(
    bar_x,
    bar_y,
    bar_x + bar_width * hp_percent,
    bar_y + bar_height,
    false
);

// Reset color
draw_set_color(c_white);