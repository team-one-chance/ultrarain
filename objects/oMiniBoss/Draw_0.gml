// =====================================
// ENEMY HP BAR
// =====================================

var bar_width = 60;
var bar_height = 5;
var bar_gap = 13;

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
// Draw the animation around the same body centre in both directions.
// Never change image_xscale or the collision shape while drawing.
var source_direction = walk_sprite_source_direction;

if (sprite_index == stand_sprite)
{
    source_direction = shield_hp > 0
        ? stand_sprite_source_direction
        : stand_no_shield_source_direction;
}
else if (sprite_index == normal_attack)
{
    source_direction = shield_hp > 0
        ? attack_sprite_source_direction
        : attack_no_shield_source_direction;
}
else if (sprite_index == jump_sprite)
{
    source_direction = jump_sprite_source_direction;
}
else if (sprite_index == hit_sprite)
{
    source_direction = hit_sprite_source_direction;
}
else if (sprite_index == defend_sprite)
{
    source_direction = defend_sprite_source_direction;
}
else if (sprite_index == stun_sprite)
{
    source_direction = stun_sprite_source_direction;
}

var displayed_xscale =
    abs(image_xscale) * facing_direction * source_direction;
var sprite_center_from_origin =
    sprite_get_width(sprite_index) * 0.5
    - sprite_get_xoffset(sprite_index);
var draw_x =
    (bbox_left + bbox_right) * 0.5
    - displayed_xscale * sprite_center_from_origin;

draw_sprite_ext(
    sprite_index,
    image_index,
    draw_x,
    y,
    displayed_xscale,
    image_yscale,
    image_angle,
    image_blend,
    image_alpha
);

// A small blue bar above the boss shows the remaining shield HP.
// It disappears once the shield breaks; the red boss bar is unchanged.
if (shield_hp > 0 && shield_hp_max > 0)
{
    var shield_ratio = clamp(shield_hp / shield_hp_max, 0, 1);
    var bar_left =
        (bbox_left + bbox_right) * 0.5
        - shield_bar_width * 0.5;
    var bar_top = bbox_top - shield_bar_y_offset;
    var bar_right = bar_left + shield_bar_width;
    var bar_bottom = bar_top + shield_bar_height;
    var shield_blue = make_color_rgb(50, 130, 255);
    draw_rectangle_colour(
        bar_left, bar_top, bar_right, bar_bottom,
        c_black, c_black, c_black, c_black, false
    );

    draw_rectangle_colour(
        bar_left + 1,
        bar_top + 1,
        bar_left + 1 + (shield_bar_width - 2) * shield_ratio,
        bar_bottom - 1,
        shield_blue, shield_blue, shield_blue, shield_blue, false
    );
}
