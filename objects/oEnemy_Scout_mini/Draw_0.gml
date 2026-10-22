

// =====================================
// DRAW ENEMY
// =====================================

draw_sprite_ext(
    sprite_index,
    image_index,
    (bbox_left + bbox_right) * 0.5 - scout_facing * sprite_get_width(sprite_index) * scout_scale * 0.5,
    bbox_bottom + 1 - sprite_get_height(sprite_index) * scout_scale,
    scout_facing * scout_scale,
    scout_scale,
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
// White outline
var bar_outline = 2;

draw_set_color(c_white);

draw_rectangle(
    bar_x - bar_outline,
    bar_y - bar_outline,
    bar_x + bar_width + bar_outline,
    bar_y + bar_height + bar_outline,
    false
);
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

if (hp_percent > 0)
{
    draw_rectangle(
        bar_x,
        bar_y,
        bar_x + bar_width * hp_percent,
        bar_y + bar_height,
        false
    );
}

draw_set_color(old_colour);



// Reset
draw_set_color(c_white);

