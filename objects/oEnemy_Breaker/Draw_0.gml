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
// Phase one flashes shield markings; phase two flashes every red body marking.
var _shield_flash = breaker_shield_flash_time > 0 && !breaker_unshielded
    && variable_struct_exists(breaker_shield_axes, _sprite_name)
    && shader_is_compiled(sh_BreakerShieldFlash);
var _body_flash = breaker_unshielded && breaker_body_flash_time > 0
    && shader_is_compiled(sh_BreakerShieldFlash);
if (_shield_flash || _body_flash) {
    shader_set(sh_BreakerShieldFlash);
    shader_set_uniform_f(breaker_body_flash_uniform, _body_flash ? 1 : 0);
    var _flash_time = _body_flash ? breaker_body_flash_time : breaker_shield_flash_time;
    shader_set_uniform_f(breaker_shield_flash_amount_uniform,
        min(1, _flash_time / (breaker_shield_flash_duration * 0.5)));
}
if (_shield_flash) {
    var _axes = variable_struct_get(breaker_shield_axes, _sprite_name);
    var _axis = _axes[clamp(floor(image_index), 0, array_length(_axes) - 1)];
    var _x1 = (_axis[0] - sprite_get_xoffset(sprite_index)) * _scale_x;
    var _y1 = (_axis[1] - sprite_get_yoffset(sprite_index)) * image_yscale;
    var _x2 = (_axis[2] - sprite_get_xoffset(sprite_index)) * _scale_x;
    var _y2 = (_axis[3] - sprite_get_yoffset(sprite_index)) * image_yscale;
    var _cos = dcos(image_angle);
    var _sin = dsin(image_angle);
    shader_set_uniform_f(breaker_shield_flash_axis_uniform,
        _draw_x + _x1 * _cos + _y1 * _sin, _draw_y - _x1 * _sin + _y1 * _cos,
        _draw_x + _x2 * _cos + _y2 * _sin, _draw_y - _x2 * _sin + _y2 * _cos);
    shader_set_uniform_f(breaker_shield_flash_radius_uniform, 5 * abs(image_yscale));
}
draw_sprite_ext(sprite_index, image_index, _draw_x, _draw_y,
    _scale_x, image_yscale, image_angle, image_blend, image_alpha);
if (_shield_flash || _body_flash) shader_reset();

breaker_update_eye_glow(_draw_x, _draw_y, _scale_x);
var _eye_lighting = instance_find(o_Lighting, 0);
var _eye_deferred = false;
if (instance_exists(_eye_lighting) && view_enabled) {
    _eye_deferred = _eye_lighting.enabled && view_camera[view_current] != -1
        && surface_exists(_eye_lighting.light_surface)
        && !(variable_global_exists("dev_freecam") && global.dev_freecam);
}
if (!_eye_deferred) breaker_draw_eye_glow();

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

var _warning_color = c_white;
var _show_warning = false;

if (breaker_state == BreakerState.BASH)
{
    _warning_color = breaker_unshielded ? c_yellow : c_red;
    _show_warning = true;
}
else if (breaker_state == BreakerState.JUMP_CHARGE
    || breaker_airborne_attack())
{
    _warning_color = c_blue;
    _show_warning = true;
}

if (_show_warning)
{
    var _old_warning_color = draw_get_color();
    var _old_warning_alpha = draw_get_alpha();

    draw_set_color(_warning_color);
    draw_set_alpha(0.8);

    draw_ellipse(
        bbox_left - 8,
        bbox_top - 8,
        bbox_right + 8,
        bbox_bottom + 8,
        true
    );

    draw_set_color(_old_warning_color);
    draw_set_alpha(_old_warning_alpha);
}