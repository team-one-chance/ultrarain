// =====================================
// CHARGED BEAM GLOW
// =====================================
var _old_colour = draw_get_color();
var _old_alpha = draw_get_alpha();

if (beam_coins_used > 1)
{
    var _facing = sign(image_xscale);
    if (_facing == 0) _facing = 1;

    var _centre_y = (bbox_top + bbox_bottom) * 0.5;
    var _rear_x = (_facing > 0) ? bbox_left : bbox_right;
    var _front_x = (_facing > 0) ? bbox_right : bbox_left;
    var _pulse = 0.85 + 0.15 * sin(beam_age * 16);
    var _glow_alpha = min(0.4, 0.12 + 0.04 * (beam_coins_used - 1));

    draw_set_color(make_colour_rgb(80, 230, 255));
    draw_set_alpha(_old_alpha * _glow_alpha * _pulse);

    draw_line_width(
        _rear_x - _facing * 12 * beam_aoe_scale,
        _centre_y,
        _front_x,
        _centre_y,
        max(2, bbox_bottom - bbox_top + 6 * beam_aoe_scale)
    );
}

draw_set_color(_old_colour);
draw_set_alpha(_old_alpha);
draw_self();

// Brief white flare on multi-coin release.
if (beam_coins_used > 1 && beam_age < 0.14)
{
    var _flare_x = (image_xscale > 0) ? bbox_left : bbox_right;
    var _flare_y = (bbox_top + bbox_bottom) * 0.5;

    draw_set_color(c_white);
    draw_set_alpha(_old_alpha * (1 - beam_age / 0.14));
    draw_circle(_flare_x, _flare_y, 5 * beam_aoe_scale, false);
}

draw_set_color(_old_colour);
draw_set_alpha(_old_alpha);
