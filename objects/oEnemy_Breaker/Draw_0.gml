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
// Register every cropped animation against the same original canvas anchor.
var _scale_x = abs(image_xscale) * facing_direction * breaker_source_direction;
var _offset = variable_struct_get(breaker_crop_offsets, sprite_get_name(sprite_index));
var _draw_x = (bbox_left + bbox_right) * 0.5
    + (_offset[0] - breaker_anchor_x + sprite_get_xoffset(sprite_index)) * _scale_x;
var _draw_y = bbox_bottom + 1
    + (_offset[1] - breaker_anchor_y + sprite_get_yoffset(sprite_index)) * image_yscale;
// Slam/land art uses different original canvas baselines between frames.
var _sprite_name = sprite_get_name(sprite_index);
if (variable_struct_exists(breaker_foot_offsets, _sprite_name)) {
    var _feet = variable_struct_get(breaker_foot_offsets, _sprite_name);
    var _frame = clamp(floor(image_index), 0, array_length(_feet) - 1);
    _draw_y = bbox_bottom + 1
        + (sprite_get_yoffset(sprite_index) - _feet[_frame]) * image_yscale;
}
draw_sprite_ext(sprite_index, image_index, _draw_x, _draw_y,
    _scale_x, image_yscale, image_angle, image_blend, image_alpha);

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
