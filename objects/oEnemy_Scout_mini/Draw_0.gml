

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
// CHARGE RING
// =====================================

if (attack_state == 2 && sprite_index == s_Scout_charge)
{
    var _charge_half_width = sprite_get_width(sprite_index) * scout_scale * 0.5; // Half the drawn width, in room pixels.
    var _charge_half_height = sprite_get_height(sprite_index) * scout_scale * 0.5; // Half the drawn height, in room pixels.
    var _charge_cx = (bbox_left + bbox_right) * 0.5; // Horizontal visual centre, in room pixels.
    var _charge_cy = bbox_bottom + 1 - _charge_half_height; // Vertical visual centre, matching the sprite placement.
    var _charge_progress = scout_animation_time / scout_animation_duration(s_Scout_charge); // Completion from 0 to 1, including playback variation.
    draw_charge_ring(_charge_cx, _charge_cy, _charge_half_width, _charge_half_height, _charge_progress);
}

// =====================================
// CARTOON STUN STARS
// =====================================

// Cover every stun source and all three visible stun animation stages.
var _stars_stun_pose = sprite_index == s_Scout_stunEnter
    || sprite_index == s_Scout_stun || sprite_index == s_Scout_stunExit;
if (stun_timer > 0 || slam_stun_timer > 0 || slam_knockback_timer > 0
    || _stars_stun_pose)
{
    var _stars_old_color = draw_get_color();
    var _stars_old_alpha = draw_get_alpha();
    var _stars_remaining = max(stun_timer, max(slam_stun_timer, slam_knockback_timer));
    // Keep a faint star visible on the final recovery frame after timers expire.
    if (_stars_stun_pose) _stars_remaining = max(_stars_remaining, 0.016);
    var _stars_alpha = image_alpha * clamp(_stars_remaining / 0.15, 0, 1);
    var _stars_x = (bbox_left + bbox_right) * 0.5;
    var _head_top = bbox_bottom + 1 - sprite_get_height(sprite_index) * scout_scale;
    // Leave room for the HP bar below the orbit.
    var _stars_y = min(_head_top, bbox_top) - 22;
    var _orbit_width = 11 * scout_scale;
    var _orbit_height = 3 * scout_scale;

    draw_set_alpha(_stars_alpha);
    for (var _star = 0; _star < 3; ++_star)
    {
        var _orbit_angle = scout_stun_elapsed * 240 + _star * 120;
        var _star_x = _stars_x + dcos(_orbit_angle) * _orbit_width;
        var _star_y = _stars_y + dsin(_orbit_angle) * _orbit_height;
        var _star_radius = 2.8 * scout_scale * (1 + 0.12 * dsin(_orbit_angle));
        var _star_rotation = 90 + scout_stun_elapsed * 90;

        // Draw a dark gold border, then a bright five-pointed star.
        for (var _pass = 0; _pass < 2; ++_pass)
        {
            var _outer_radius = _star_radius + (_pass == 0 ? 1 : 0);
            draw_set_color(_pass == 0 ? make_color_rgb(130, 75, 10) : make_color_rgb(255, 225, 65));
            draw_primitive_begin(pr_trianglefan);
            draw_vertex(_star_x, _star_y);
            for (var _point = 0; _point <= 10; ++_point)
            {
                var _point_angle = _star_rotation + _point * 36;
                var _point_radius = _outer_radius * (_point mod 2 == 0 ? 1 : 0.45);
                draw_vertex(_star_x + lengthdir_x(_point_radius, _point_angle),
                    _star_y + lengthdir_y(_point_radius, _point_angle));
            }
            draw_primitive_end();
        }
    }
    draw_set_alpha(_stars_old_alpha);
    draw_set_color(_stars_old_color);
}

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

