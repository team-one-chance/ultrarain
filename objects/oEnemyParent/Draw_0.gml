

// =====================================
// DRAW ENEMY
// =====================================

draw_sprite_ext(
    sprite_index,
    image_index,
    x + attack_shake_x,
    y + attack_shake_y,
    image_xscale,
    image_yscale,
    image_angle,
    image_blend,
    image_alpha
);



// =====================================
// ENEMY HP BAR
// =====================================

var bar_width = 40;
var bar_height = 5;

var bar_x = x - (bar_width / 2);
var bar_y = y - 35;

var hp_percent = ehp / ehp_max;

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
draw_set_color(c_red);

draw_rectangle(
    bar_x,
    bar_y,
    bar_x + (bar_width * hp_percent),
    bar_y + bar_height,
    false
);


// Reset
draw_set_color(c_white);

