// VFX means visual effects. Every Breaker impact holds the SAME global settings struct.
visual_settings = breaker_slam_visual_settings(); // Shared reference; no room-specific copies or overrides.
effect_age_seconds = 0; // Elapsed animation time, advanced by the game's simulation clock.
defer_to_lighting = false; // True only when the active lighting controller will draw this impact.
wind_puffs = []; // Dust-puff variation; positions and lifetime are derived from the shared settings.

for (var _puff_index = 0; _puff_index < max(0, floor(visual_settings.dust_count)); _puff_index++)
{
    array_push(wind_puffs, {
        side: (_puff_index mod 2) == 0 ? -1 : 1, // Alternate left and right for a balanced burst.
        delay_fraction: random_range(0, 0.16), // Spawn delay relative to the configured lifetime.
        lifetime_fraction: random_range(0.54, 0.82), // Puff lifetime relative to the configured lifetime.
        spread_fraction: random_range(0.45, 0.8), // How much of the configured radius this puff covers.
        lift_fraction: random_range(0.11, 0.39), // Vertical rise relative to the configured wind height.
        size_fraction: random_range(0.5, 1) // Multiplier of the configured dust-puff size.
    });
}

// Draw one tapered ribbon following a cubic curve; _side is -1 for left, +1 for right.
draw_pressure_crescent = function(_side, _front, _height, _width, _opacity)
{
    var _curve_start = _front * 0.12; // Start of the low ground ribbon, in pixels from the impact.
    var _curve_middle = _front * 0.78; // First control point pulls the ribbon along the floor.
    var _curve_tip = _front - _height * 0.45; // The tip curls back toward the impact.
    var _segments = 24; // Curve tessellation; higher values smooth the silhouette.
    draw_primitive_begin(pr_trianglestrip);
    for (var _segment = 0; _segment <= _segments; _segment++)
    {
        var _t = _segment / _segments; // Normalized position along the curve, from 0 to 1.
        var _u = 1 - _t; // Complement used by the cubic curve formula.
        var _taper = power(max(0, sin(pi * _t)), 0.7); // Thin ribbon ends and a fuller middle.
        var _curve_x = _u * _u * _u * _curve_start + 3 * _u * _u * _t * _curve_middle
            + 3 * _u * _t * _t * _front + _t * _t * _t * _curve_tip;
        var _curve_y = -2 - _height * (0.6 * _u * _t * _t + _t * _t * _t);
        var _tangent_x = 3 * _u * _u * (_curve_middle - _curve_start)
            + 6 * _u * _t * (_front - _curve_middle) + 3 * _t * _t * (_curve_tip - _front);
        var _tangent_y = -_height * (1.2 * _u * _t + 2.4 * _t * _t);
        var _tangent_length = max(0.001, sqrt(sqr(_tangent_x) + sqr(_tangent_y)));
        var _normal_x = -_tangent_y / _tangent_length * _width * _taper * 0.5;
        var _normal_y = _tangent_x / _tangent_length * _width * _taper * 0.5;
        draw_vertex_color(x + _side * (_curve_x + _normal_x), y + _curve_y + _normal_y,
            visual_settings.wind_colour, _opacity * _taper);
        draw_vertex_color(x + _side * (_curve_x - _normal_x), y + _curve_y - _normal_y,
            visual_settings.shade_colour, _opacity * _taper * 0.35);
    }
    draw_primitive_end();
};

draw_pressure_burst = function()
{
    var _old_colour = draw_get_color(); // Restore the caller's drawing state after the effect.
    var _old_opacity = draw_get_alpha();
    var _duration = max(0.001, visual_settings.duration_seconds); // Protect normalized timing from division by zero.
    var _progress = clamp(effect_age_seconds / _duration, 0, 1); // All animation timing uses this single clock.
    var _radius = max(0, visual_settings.radius_pixels); // No hidden cap or radius supplied by the room.
    var _opacity = clamp(visual_settings.opacity, 0, 1); // Global visibility multiplier for every layer.

    for (var _puff_index = 0; _puff_index < array_length(wind_puffs); _puff_index++)
    {
        var _puff = wind_puffs[_puff_index]; // Variation chosen once when this impact was created.
        var _puff_time = _progress - _puff.delay_fraction;
        if (_puff_time <= 0 || _puff_time >= _puff.lifetime_fraction) continue;
        var _puff_progress = _puff_time / _puff.lifetime_fraction;
        var _expansion = 1 - power(1 - _puff_progress, 3); // Fast initial rush, followed by drag.
        var _puff_x = x + _puff.side * _radius * _puff.spread_fraction * _expansion;
        var _puff_y = y - 2 - visual_settings.wind_height_pixels * _puff.lift_fraction * _puff_progress;
        var _size = max(0, visual_settings.dust_size_pixels) * _puff.size_fraction * (0.5 + _puff_progress);
        draw_set_color(visual_settings.shade_colour);
        draw_set_alpha(_opacity * clamp(visual_settings.dust_opacity, 0, 1) * sin(pi * _puff_progress));
        draw_ellipse(_puff_x - _size, _puff_y - _size * 0.5,
            _puff_x + _size, _puff_y + _size * 0.5, false);
    }

    var _layer_count = max(0, floor(visual_settings.wind_layers)); // Zero hides the ribbons but retains dust and flash.
    var _layer_delay = max(0, visual_settings.layer_delay_fraction); // Fraction of total duration between ribbons.
    var _ribbon_lifetime = max(0.01, 1 - max(0, _layer_count - 1) * _layer_delay);
    draw_set_alpha(1);
    for (var _side = -1; _side <= 1; _side += 2)
    {
        for (var _wave = 0; _wave < _layer_count; _wave++)
        {
            var _wave_time = _progress - _wave * _layer_delay;
            if (_wave_time < 0 || _wave_time >= _ribbon_lifetime) continue;
            var _wave_progress = _wave_time / _ribbon_lifetime;
            var _expansion = 1 - power(1 - _wave_progress, 3);
            var _layer_scale = power(0.85, _wave); // Inner ribbons are proportionally smaller and fainter.
            var _front = lerp(min(7, _radius), _radius * _layer_scale, _expansion);
            var _height = max(0, visual_settings.wind_height_pixels) * _layer_scale * lerp(0.28, 1, _expansion);
            var _width = max(0, visual_settings.wind_width_pixels) * _layer_scale * (1 - _wave_progress * 0.5);
            var _wave_opacity = _opacity * power(1 - _wave_progress, 0.8) * power(0.75, _wave);
            draw_pressure_crescent(_side, _front, _height, _width, _wave_opacity);
            var _tail = max(0, _front - _radius * lerp(0.375, 0.11, _wave_progress));
            var _floor_y = y - 2 - _wave * visual_settings.wind_height_pixels / 6;
            draw_set_color(visual_settings.wind_colour);
            draw_set_alpha(_wave_opacity * 0.5);
            draw_triangle(x + _side * _front, _floor_y,
                x + _side * _tail, _floor_y - _width * 0.23,
                x + _side * _tail, _floor_y + _width * 0.23, false);
            draw_set_alpha(1);
        }
    }

    var _flash_fraction = clamp(visual_settings.flash_duration_fraction, 0, 1); // Zero disables the contact flash.
    if (_progress < _flash_fraction)
    {
        var _flash_fade = 1 - _progress / _flash_fraction;
        var _flash_radius = max(0, visual_settings.flash_radius_pixels);
        draw_set_color(visual_settings.flash_colour);
        draw_set_alpha(_opacity * _flash_fade * 0.85);
        draw_triangle(x - _flash_radius * 0.86, y - 2,
            x, y - max(0, visual_settings.flash_height_pixels) * _flash_fade - 2,
            x + _flash_radius * 0.86, y - 2, false);
        draw_set_alpha(_opacity * _flash_fade * 0.45);
        draw_ellipse(x - _flash_radius, y - 4, x + _flash_radius, y, false);
    }
    draw_set_color(_old_colour);
    draw_set_alpha(_old_opacity);
};
