// Place one controller per room. enabled and ambient_color are editor properties.
// Ambient channels: 255 = original scene brightness.
depth = -13000;
// Cone rendering mode is configured here.
cone_shader_enabled = true;
cone_dither_strength = 1;
cone_origin_uniform = shader_get_uniform(sh_CeilingCone, "u_origin");
cone_transform_uniform = shader_get_uniform(sh_CeilingCone, "u_transform");
cone_shape_uniform = shader_get_uniform(sh_CeilingCone, "u_shape");
cone_strength_uniform = shader_get_uniform(sh_CeilingCone, "u_strength");
cone_dither_uniform = shader_get_uniform(sh_CeilingCone, "u_dither");
//ambient_color = make_color_rgb(210, 216, 225);
//ambient_color = make_color_rgb(60, 66, 75);
terminal_radius = 80;
terminal_strength = 0.20;
terminal_idle_color = make_color_rgb(170, 230, 205);
terminal_used_color = make_color_rgb(255, 105, 90);
demo_terminal_color = make_color_rgb(170, 210, 245);
wire_radius = 56;
wire_strength = 0.06;
wire_color = make_color_rgb(175, 205, 255);
surface_impact_radius = 32;
enemy_impact_radius = 60;
impact_strength = 0.1;
// Long ceiling lamps: sprite-local emission span and shared cone settings.
ceiling_light = {
    enabled: true,
    lamp_left: 6,
    lamp_right: 56,
    lamp_y: 4,
    length: 320,
    cone_angle: 110,
    strength: 0.60,
    falloff: 2,
    color: make_color_rgb(255, 242, 220)
};
// Strong ceiling lamps for tall rooms: deeper reach and a gentler fade.
ceiling_light_strong = {
    enabled: true,
    lamp_left: 6,
    lamp_right: 56,
    lamp_y: 4,
    length: 900,
    cone_angle: 100,
    strength: 0.65,
    falloff: 1.3,
    color: make_color_rgb(255, 242, 220)
};
// Damaged ceiling lamps: long broken intervals, brief glow pulses on frame 2.
ceiling_flicker = {
    interval_min: 0.4,
    interval_max: 2.2,
    duration_min: 0.035,
    duration_max: 0.11,
    dim_multiplier: 0.08
};
// Bloom uses explicit emitters. Scene extraction is optional; radius is in room pixels.
bloom_enabled = true;
bloom_scene_enabled = false; // Broad lit surfaces otherwise create a foggy wash.
lamp_bloom_strength = 0.65;
terminal_bloom_strength = 0.5;
bloom_threshold = 0.55;
bloom_strength = 0.30;
bloom_radius = 4;
// Extra emission width feeds the blur; the visible shot remains one pixel wide.
hitscan_bloom_width = 6;
hitscan_bloom_strength = 0.9;
bloom_resolution = 1; // Full resolution keeps thin highlights stable during camera motion.
bloom_camera = -1;
bloom_surface_a = -1;
bloom_surface_b = -1;
bloom_threshold_uniform = shader_get_uniform(sh_BloomExtract, "u_threshold");
bloom_step_uniform = shader_get_uniform(sh_BloomBlur, "u_step");
// N switches between normal rendering and the preferred pixelation size.
pixelation_enabled = true;
pixelation_size = 1.0;
pixelation_alternate_size = 1.3;
resolution_indicator_duration = 3;
resolution_indicator_timer = 0;
pixelation_surface = -1;
pixelation_camera = -1;
pixelation_grid_uniform = shader_get_uniform(sh_WorldPixelate, "u_grid");
pixelation_texel_uniform = shader_get_uniform(sh_WorldPixelate, "u_texel");
light_surface = -1;

// Draw into the light map using world coordinates and the active camera.
draw_soft_light = function(_x, _y, _radius, _color, _strength)
{
    if (_radius <= 0 || _strength <= 0) return;
    var _cam = view_camera[view_current];
    var _cx = camera_get_view_x(_cam);
    var _cy = camera_get_view_y(_cam);
    if (_x + _radius < _cx || _y + _radius < _cy
    || _x - _radius > _cx + camera_get_view_width(_cam)
    || _y - _radius > _cy + camera_get_view_height(_cam)) return;
    draw_set_alpha(clamp(_strength, 0, 1));
    draw_circle_colour(_x, _y, _radius, _color, c_black, false);
};

// Render ceiling cones using the controller settings and each lamp transform.
draw_light_cone = function(_lamp, _config, _brightness = 1)
{
    if (!_config.enabled || _config.length <= 0 || _config.strength <= 0) return;
    var _half_angle = clamp(_config.cone_angle * 0.5, 0, 85);
    var _spread = dtan(_half_angle);
    var _center = (_config.lamp_left + _config.lamp_right) * 0.5;
    var _half_width = abs(_config.lamp_right - _config.lamp_left) * 0.5;
    var _origin_x = sprite_get_xoffset(_lamp.sprite_index);
    var _origin_y = sprite_get_yoffset(_lamp.sprite_index);
    var _cos = dcos(_lamp.image_angle);
    var _sin = dsin(_lamp.image_angle);
    var _rows = 18;
    var _columns = 16;
    var _strength = clamp(_config.strength * _brightness, 0, 1);
    var _cam = view_camera[view_current];
    // Conservative bounds include rotation and stretching.
    var _reach = (_config.length + _half_width + _config.length * _spread
        + abs(_center - _origin_x) + abs(_config.lamp_y - _origin_y))
        * max(abs(_lamp.image_xscale), abs(_lamp.image_yscale));
    if (_lamp.x + _reach < camera_get_view_x(_cam)
    || _lamp.y + _reach < camera_get_view_y(_cam)
    || _lamp.x - _reach > camera_get_view_x(_cam) + camera_get_view_width(_cam)
    || _lamp.y - _reach > camera_get_view_y(_cam) + camera_get_view_height(_cam)) return;

    if (cone_shader_enabled && shader_is_compiled(sh_CeilingCone))
    {
        if (_lamp.image_xscale == 0 || _lamp.image_yscale == 0) return;
        var _anchor_x = (_center - _origin_x) * _lamp.image_xscale;
        var _anchor_y = (_config.lamp_y - _origin_y) * _lamp.image_yscale;
        shader_set(sh_CeilingCone);
        shader_set_uniform_f(cone_origin_uniform,
            _lamp.x + _anchor_x * _cos + _anchor_y * _sin,
            _lamp.y - _anchor_x * _sin + _anchor_y * _cos);
        shader_set_uniform_f(cone_transform_uniform, _cos, _sin,
            1 / _lamp.image_xscale, 1 / _lamp.image_yscale);
        shader_set_uniform_f(cone_shape_uniform, _config.length, _half_width, _spread,
            max(0.1, _config.falloff));
        shader_set_uniform_f(cone_strength_uniform, _strength);
        shader_set_uniform_f(cone_dither_uniform, max(0, cone_dither_strength));
        draw_primitive_begin(pr_trianglestrip);
        for (var _corner = 0; _corner < 4; _corner++)
        {
            var _bottom = _corner mod 2;
            var _side = _corner < 2 ? -1 : 1;
            var _distance = _bottom * _config.length;
            var _lx = (_center + _side * (_half_width + _distance * _spread)
                - _origin_x) * _lamp.image_xscale;
            var _ly = (_config.lamp_y + _distance - _origin_y) * _lamp.image_yscale;
            draw_vertex_colour(_lamp.x + _lx * _cos + _ly * _sin,
                _lamp.y - _lx * _sin + _ly * _cos, _config.color, 1);
        }
        draw_primitive_end();
        shader_reset();
        return;
    }

    // A soft trapezoid starts at the lamp strip and widens downward.
    // Vertex alpha feathers both sides and fades the bottom to zero.
    for (var _row = 0; _row < _rows; _row++)
    {
        draw_primitive_begin(pr_trianglestrip);
        for (var _column = 0; _column <= _columns; _column++)
        {
            var _u = _column / _columns * 2 - 1;
            var _edge = 1 - _u * _u;
            _edge *= _edge;
            for (var _side = 0; _side < 2; _side++)
            {
                var _t = (_row + _side) / _rows;
                var _distance = _config.length * _t;
                var _lx = (_center + _u * (_half_width + _distance * _spread)
                    - _origin_x) * _lamp.image_xscale;
                var _ly = (_config.lamp_y + _distance - _origin_y) * _lamp.image_yscale;
                var _fade = 1 - _t;
                draw_vertex_colour(
                    _lamp.x + _lx * _cos + _ly * _sin,
                    _lamp.y - _lx * _sin + _ly * _cos,
                    _config.color, _strength * _edge * power(_fade, max(0.1, _config.falloff))
                );
            }
        }
        draw_primitive_end();
    }
};

// Emission-only bloom sources, mapped onto the current screen-space buffer.
draw_bloom_line = function(_x1, _y1, _x2, _y2, _color, _width, _strength)
{
    draw_set_color(_color);
    draw_set_alpha(clamp(_strength, 0, 1));
    draw_line_width((_x1 - bloom_view_x) * bloom_scale_x, (_y1 - bloom_view_y) * bloom_scale_y,
        (_x2 - bloom_view_x) * bloom_scale_x, (_y2 - bloom_view_y) * bloom_scale_y,
        _width * bloom_scale_y);
};
draw_bloom_point = function(_x, _y, _color, _strength)
{
    draw_set_color(_color);
    draw_set_alpha(clamp(_strength, 0, 1));
    draw_circle((_x - bloom_view_x) * bloom_scale_x, (_y - bloom_view_y) * bloom_scale_y,
        2 * bloom_scale_y, false);
};
draw_lamp_bloom = function(_lamp, _config, _brightness = 1)
{
    if (!_config.enabled) return;
    var _x1 = (_config.lamp_left - sprite_get_xoffset(_lamp.sprite_index)) * _lamp.image_xscale;
    var _x2 = (_config.lamp_right - sprite_get_xoffset(_lamp.sprite_index)) * _lamp.image_xscale;
    var _y = (_config.lamp_y - sprite_get_yoffset(_lamp.sprite_index)) * _lamp.image_yscale;
    var _cos = dcos(_lamp.image_angle);
    var _sin = dsin(_lamp.image_angle);
    draw_bloom_line(_lamp.x + _x1 * _cos + _y * _sin, _lamp.y - _x1 * _sin + _y * _cos,
        _lamp.x + _x2 * _cos + _y * _sin, _lamp.y - _x2 * _sin + _y * _cos,
        _config.color, 2, lamp_bloom_strength * _brightness);
};
