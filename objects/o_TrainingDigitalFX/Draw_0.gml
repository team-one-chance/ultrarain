var _progress = age / lifetime;
draw_set_color(c_aqua);
draw_set_alpha(1 - _progress);
for (var _i = 0; _i < 16; ++_i)
{
    var _angle = seed_angle + _i * 137;
    var _x = x + lengthdir_x(10 + _progress * (20 + _i * 2), _angle);
    var _y = y + lengthdir_y(10 + _progress * (20 + _i * 2), _angle);
    draw_rectangle(_x, _y, _x + 3, _y + 2, false);
}
draw_set_alpha(1);
draw_set_color(c_white);
