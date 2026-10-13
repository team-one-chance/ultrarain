draw_set_alpha(1);

// Defer emissive centers to the lighting pass; other rooms draw normally.
var _lighting = instance_find(o_Lighting, 0);
var _deferred = false;
if (emissive && instance_exists(_lighting) && view_enabled)
{
    _deferred = _lighting.enabled
        && view_camera[view_current] != -1
        && surface_exists(_lighting.light_surface);
}
if (!_deferred)
{
    // Keep the outlined style when there is no emissive lighting pass.
    draw_set_color(c_black);
    draw_line_width(line_x1, line_y1, line_x2, line_y2, 3);
    draw_emissive_streak();
}
draw_set_alpha(1);
draw_set_color(c_white);
