// Place one controller per room. enabled and ambient_color are editor properties.
// Ambient channels: 255 = original scene brightness.
depth = -250;
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
pickup_light_radius = 0; // Room pixels; larger values spread pickup illumination farther.
pickup_light_strength = 1; // Light intensity from 0 to 1; larger values brighten the surroundings.
pickup_light_color = make_color_rgb(255, 235, 205); // Warm white light for Pinhouse and medkit pickups.
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
scout_bloom_strength = 1.5; // Independent glow gain after blur; values above 1 amplify.
scout_bloom_radius = 2; // Tighter halo keeps the red details readable.
scout_bloom_threshold = 0.55; // Keep the dark body out of the glow buffer.
// Player cyan accents: match hue, preserving the original sharp rig rendering.
player_bloom_strength = 2.0; // Independent post-blur gain; 0 disables.
player_bloom_radius = 0.5; // Tight halo around the thin face strip and arm accent.
player_bloom_color = make_color_rgb(0, 186, 225);
player_bloom_tolerance = 0.08;
player_bloom_feather = 0.04;
player_bloom_min_brightness = 0.45;
lava_bloom_strength = 1.0; // Independent of the subtle scene bloom strength.
lava_bloom_radius = 12;
lava_bloom_occluder_layer = "dark_outsidevent";
bloom_threshold = 0.55;
bloom_strength = 0.30;
bloom_radius = 4;
// Extra emission width feeds the blur; the visible shot remains one pixel wide.
hitscan_bloom_width = 6;
hitscan_bloom_strength = 0.9;
bloom_resolution = 0.5; // Fraction of application resolution; half size shades 75% fewer pixels, capped at world resolution.
bloom_camera = -1;
bloom_surface_a = -1;
bloom_surface_b = -1;
bloom_threshold_uniform = shader_get_uniform(sh_BloomExtract, "u_threshold");
bloom_gain_uniform = shader_get_uniform(sh_BloomExtract, "u_gain");
bloom_step_uniform = shader_get_uniform(sh_BloomBlur, "u_step");
player_glow_color_uniform = shader_get_uniform(sh_PlayerGlowExtract, "u_glow_color");
player_glow_tolerance_uniform = shader_get_uniform(sh_PlayerGlowExtract, "u_tolerance");
player_glow_feather_uniform = shader_get_uniform(sh_PlayerGlowExtract, "u_feather");
player_glow_brightness_uniform = shader_get_uniform(sh_PlayerGlowExtract, "u_min_brightness");
// Pixelization is a shared display preference, retained across rooms and retries.
pixelation_enabled = true;
pixelation_size = menu_pixelization_active() ? 1.3 : 1.0;
pixelation_alternate_size = 1.3;
resolution_indicator_duration = 3;
resolution_indicator_timer = 0;
pixelation_surface = -1;
pixelation_camera = -1;
pixelation_grid_uniform = shader_get_uniform(sh_WorldPixelate, "u_grid");
pixelation_texel_uniform = shader_get_uniform(sh_WorldPixelate, "u_texel");
light_surface = -1;
light_resolution = 0.5; // Fraction of world resolution; smooth illumination does not need full-size buffers.
light_pixel_budget = 259200; // Maximum light-map pixels (720 x 360); wider views trade buffer detail for stable cost.

// Include blur spill outside the view so halos do not pop at screen edges.
bloom_source_visible = function(_source, _padding)
{
    if (!_source.visible || _source.image_alpha <= 0 || !layer_get_visible(_source.layer)) return false;
    var _cam = view_camera[view_current];
    return _source.bbox_right + _padding >= camera_get_view_x(_cam)
        && _source.bbox_bottom + _padding >= camera_get_view_y(_cam)
        && _source.bbox_left - _padding <= camera_get_view_x(_cam) + camera_get_view_width(_cam)
        && _source.bbox_top - _padding <= camera_get_view_y(_cam) + camera_get_view_height(_cam);
};

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
    // Bound the actual trapezoid; the old radius also admitted cones pointing away from the view.
    var _anchor_x = (_center - _origin_x) * _lamp.image_xscale;
    var _anchor_y = (_config.lamp_y - _origin_y) * _lamp.image_yscale;
    var _top_x = _lamp.x + _anchor_x * _cos + _anchor_y * _sin;
    var _top_y = _lamp.y - _anchor_x * _sin + _anchor_y * _cos;
    var _bottom_x = _top_x + _config.length * _lamp.image_yscale * _sin;
    var _bottom_y = _top_y + _config.length * _lamp.image_yscale * _cos;
    var _top_extent_x = abs(_half_width * _lamp.image_xscale * _cos);
    var _top_extent_y = abs(_half_width * _lamp.image_xscale * _sin);
    var _bottom_width = _half_width + _config.length * _spread;
    var _bottom_extent_x = abs(_bottom_width * _lamp.image_xscale * _cos);
    var _bottom_extent_y = abs(_bottom_width * _lamp.image_xscale * _sin);
    if (max(_top_x + _top_extent_x, _bottom_x + _bottom_extent_x) < camera_get_view_x(_cam)
    || max(_top_y + _top_extent_y, _bottom_y + _bottom_extent_y) < camera_get_view_y(_cam)
    || min(_top_x - _top_extent_x, _bottom_x - _bottom_extent_x) > camera_get_view_x(_cam) + camera_get_view_width(_cam)
    || min(_top_y - _top_extent_y, _bottom_y - _bottom_extent_y) > camera_get_view_y(_cam) + camera_get_view_height(_cam)) return;

    if (cone_shader_enabled && shader_is_compiled(sh_CeilingCone))
    {
        if (_lamp.image_xscale == 0 || _lamp.image_yscale == 0) return;
        shader_set(sh_CeilingCone);
        shader_set_uniform_f(cone_origin_uniform,
            _top_x, _top_y);
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

// Draw black through the cover's alpha to attenuate only the lava bloom buffer.
// The caller supplies the world camera and normal alpha blending.
draw_lava_bloom_occluder = function()
{
    var _layer = layer_get_id(lava_bloom_occluder_layer);
    if (_layer == -1) return;
    if (!layer_get_visible(_layer)) return;

    var _elements = layer_get_all_elements(_layer);
    var _offset_x = layer_get_x(_layer);
    var _offset_y = layer_get_y(_layer);
    for (var _i = 0; _i < array_length(_elements); _i++)
    {
        var _element = _elements[_i];
        if (layer_get_element_type(_element) != layerelementtype_sprite) continue;
        var _sprite = layer_sprite_get_sprite(_element);
        if (_sprite == -1) continue;
        draw_sprite_ext(_sprite, layer_sprite_get_index(_element),
            _offset_x + layer_sprite_get_x(_element),
            _offset_y + layer_sprite_get_y(_element),
            layer_sprite_get_xscale(_element), layer_sprite_get_yscale(_element),
            layer_sprite_get_angle(_element), c_black, layer_sprite_get_alpha(_element));
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
