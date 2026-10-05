

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
var bar_gap = 8;

// Centre horizontally over the enemy.
var bar_x = (bbox_left + bbox_right) * 0.5
    - bar_width * 0.5;

// Position above the enemy.
var bar_y = bbox_top - bar_height - bar_gap;

var hp_percent = clamp(ehp / ehp_max, 0, 1);
var old_colour = draw_get_color();

// Background
draw_set_color(c_black);

draw_rectangle(
    bar_x,
    bar_y,
    bar_x + bar_width,
    bar_y + bar_height,
    false
);

// Remaining HP
draw_set_color(c_red);

draw_rectangle(
    bar_x,
    bar_y,
    bar_x + bar_width * hp_percent,
    bar_y + bar_height,
    false
);

draw_set_color(old_colour);

// Reset
draw_set_color(c_white);

