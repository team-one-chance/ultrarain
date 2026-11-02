var _old_colour = draw_get_color();
var _old_alpha = draw_get_alpha();

if (beam_lightning)
{
    // Match Bulletflash's emissive rendering, including rooms with lighting disabled.
    var _lighting = instance_find(o_Lighting, 0);
    var _deferred = false;
    if (instance_exists(_lighting) && view_enabled)
    {
        _deferred = _lighting.enabled && view_camera[view_current] != -1
            && surface_exists(_lighting.light_surface);
    }
    if (!_deferred) draw_electrical_beam();
}
else
{
    draw_self();
}

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
