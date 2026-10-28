line_x1 = 0;
line_y1 = 0;
line_x2 = 0;
line_y2 = 0;
line_color = c_yellow;
line_width = 1;
emissive = true; // Full brightness before bloom.
coin_effect_strength = 0;
coin_effect_width = 1;
bullet_fiery = false;
bullet_lightning = false;
lightning_points = [];

set_coin_effects = function(_bounces, _bullet_flash = false)
{
    bullet_lightning = _bullet_flash;
    bullet_fiery = !bullet_lightning && _bounces >= 4;
    coin_effect_strength = _bounces < 2 ? 0 : (bullet_fiery ? 0.45 : (_bounces >= 3 ? 0.3 : 0.14));
    coin_effect_width = line_width * (bullet_fiery ? 2 : (_bounces >= 3 ? 1.7 : 1.3));
    if (bullet_lightning)
    {
        line_color = make_color_rgb(155, 220, 255);
        var _length = point_distance(line_x1, line_y1, line_x2, line_y2);
        var _nx = _length > 0 ? -(line_y2 - line_y1) / _length : 0;
        var _ny = _length > 0 ? (line_x2 - line_x1) / _length : 0;
        var _steps = clamp(ceil(_length / 14), 2, 100);
        lightning_points = [];
        for (var _i = 0; _i <= _steps; _i++)
        {
            var _t = _i / _steps;
            // Stable zigzags keep both ends anchored to the actual hit points.
            var _offset = 0;
            if (_i > 0 && _i < _steps)
                _offset = ((_i mod 2) == 0 ? 1 : -1) * line_width
                    * (0.8 + abs(sin(_i * 2.37 + line_x1 * 0.031 + line_y1 * 0.017)));
            array_push(lightning_points, [lerp(line_x1, line_x2, _t) + _nx * _offset,
                lerp(line_y1, line_y2, _t) + _ny * _offset]);
        }
    }
};

// Rounded layers belong to the bullet and share its brief lifetime.
draw_bullet_layer = function(_color, _width, _alpha)
{
    draw_set_color(_color);
    draw_set_alpha(_alpha);
    draw_line_width(line_x1, line_y1, line_x2, line_y2, _width);
    draw_circle(line_x1, line_y1, _width * 0.5, false);
    draw_circle(line_x2, line_y2, _width * 0.5, false);
};

draw_lightning_bullet = function()
{
    var _blue = make_color_rgb(45, 125, 255);
    var _ice = make_color_rgb(135, 220, 255);
    for (var _i = 1; _i < array_length(lightning_points); _i++)
    {
        var _a = lightning_points[_i - 1];
        var _b = lightning_points[_i];
        draw_set_color(_blue);
        draw_set_alpha(0.3);
        draw_line_width(_a[0], _a[1], _b[0], _b[1], line_width * 2);
        draw_set_color(_ice);
        draw_set_alpha(1);
        draw_line_width(_a[0], _a[1], _b[0], _b[1], line_width);
        draw_set_color(c_white);
        draw_line_width(_a[0], _a[1], _b[0], _b[1], line_width * 0.45);
        if ((_i mod 5) == 0 && _i < array_length(lightning_points) - 1)
        {
            // Short blue forks stay attached to the bolt and vanish with it.
            var _direction = point_direction(_a[0], _a[1], _b[0], _b[1]);
            var _side = ((_i mod 2) == 0) ? 55 : -55;
            var _fork_x = _b[0] + lengthdir_x(line_width * 4, _direction + _side);
            var _fork_y = _b[1] + lengthdir_y(line_width * 4, _direction + _side);
            draw_set_color(_ice);
            draw_set_alpha(0.7);
            draw_line_width(_b[0], _b[1], _fork_x, _fork_y, line_width * 0.4);
            draw_set_color(_blue);
            draw_set_alpha(0.4);
            draw_line_width(_fork_x, _fork_y,
                _fork_x + lengthdir_x(line_width * 2, _direction - _side * 0.5),
                _fork_y + lengthdir_y(line_width * 2, _direction - _side * 0.5), line_width * 0.2);
        }
    }
};

// Also called by o_Lighting after ambient dimming.
draw_emissive_streak = function()
{
    var _color = draw_get_color();
    var _alpha = draw_get_alpha();
    if (!bullet_lightning && coin_effect_strength > 0)
        draw_bullet_layer(c_red, coin_effect_width, coin_effect_strength);
    if (bullet_lightning)
    {
        draw_lightning_bullet();
    }
    else if (bullet_fiery)
    {
        // Molten orange body and a narrow hot core, directly on the shot.
        draw_bullet_layer(make_color_rgb(255, 75, 12), line_width * 1.25, 0.85);
        draw_bullet_layer(make_color_rgb(255, 150, 35), line_width, 1);
        draw_bullet_layer(make_color_rgb(255, 235, 150), line_width * 0.4, 1);
    }
    else
    {
        draw_bullet_layer(line_color, line_width, 1);
    }
    draw_set_color(_color);
    draw_set_alpha(_alpha);
};

// The bullet and all its effects disappear together.
life = 0.005;
