if (basher_ready)
{
    basher_draw_leg(0);
    basher_draw_leg(1);
}
var _pivot = basher_config.body_pivot;
basher_draw_part(sBasherBody, _pivot, x + _pivot[0], y + _pivot[1], 0, 1, image_blend);
if (basher_ready)
{
    basher_draw_leg(2);
    basher_draw_leg(3);
}
