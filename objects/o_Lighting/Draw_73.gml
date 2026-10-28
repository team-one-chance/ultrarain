if (variable_global_exists("dev_freecam") && global.dev_freecam) exit;
if (!enabled || !view_enabled) exit;
var _cam = view_camera[view_current];
if (_cam == -1) exit;
var _cx = camera_get_view_x(_cam);
var _cy = camera_get_view_y(_cam);
var _vw = camera_get_view_width(_cam);
var _vh = camera_get_view_height(_cam);
var _w = max(1, ceil(_vw));
var _h = max(1, ceil(_vh));
if (surface_exists(light_surface))
{
    if (surface_get_width(light_surface) != _w || surface_get_height(light_surface) != _h)
    {
        surface_free(light_surface);
        light_surface = -1;
    }
}
if (!surface_exists(light_surface)) light_surface = surface_create(_w, _h);
if (!surface_exists(light_surface)) exit;
var _old_color = draw_get_color();
var _old_alpha = draw_get_alpha();
var _world = matrix_get(matrix_world);
var _view = matrix_get(matrix_view);
var _projection = matrix_get(matrix_projection);
surface_set_target(light_surface);
camera_apply(_cam);
draw_clear_alpha(ambient_color, 1);
gpu_set_blendmode(bm_add);
var _renderer = id;
with (o_PointLight)
{
    if (light_enabled)
        _renderer.draw_soft_light(x, y, light_radius, light_color, light_strength);
}
with (o_light_ceil_long)
{
    _renderer.draw_light_cone(id, _renderer.ceiling_light);
}
with (o_light_ceil_long_strong)
{
    _renderer.draw_light_cone(id, _renderer.ceiling_light_strong);
}
with (o_light_ceil_long_ow)
{
    var _brightness = image_index < 1 ? _renderer.ceiling_flicker.dim_multiplier : 1;
    _renderer.draw_light_cone(id, _renderer.ceiling_light, _brightness);
}
with (o_DoorController)
{
    if (!layer_get_visible(layer)) continue;
    var _terminal_color = controller_state == 0
        ? _renderer.terminal_idle_color
        : _renderer.terminal_used_color;
    _renderer.draw_soft_light((bbox_left + bbox_right) * 0.5,
        (bbox_top + bbox_bottom) * 0.5, _renderer.terminal_radius,
        _terminal_color, _renderer.terminal_strength);
}
with (o_DemoTerminal)
{
    if (!layer_get_visible(layer)) continue;
    _renderer.draw_soft_light((bbox_left + bbox_right) * 0.5,
        (bbox_top + bbox_bottom) * 0.5, _renderer.terminal_radius,
        _renderer.demo_terminal_color, _renderer.terminal_strength);
}
with (o_Block_wires)
{
    if (!layer_get_visible(layer)) continue;
    for (var _i = 0; _i < array_length(wire_arcs); _i++)
    {
        var _arc = wire_arcs[_i];
        _renderer.draw_soft_light(x + _arc.anchor_x * image_xscale,
            y + _arc.anchor_y * image_yscale, _renderer.wire_radius,
            _renderer.wire_color, _renderer.wire_strength);
    }
}
with (o_ShotImpact)
{
    var _fade = 0;
    for (var _i = 0; _i < array_length(particles); _i++)
    {
        var _p = particles[_i];
        if (!_p.dust) _fade = max(_fade, _p.life / _p.duration);
    }
    _renderer.draw_soft_light(x, y,
        impact_enemy ? _renderer.enemy_impact_radius : _renderer.surface_impact_radius,
        spark_color_start, _renderer.impact_strength * _fade * _fade);
}
with (oEnemy_Breaker)
{
    if (!breaker_eyes_awake || is_undefined(breaker_eye_light)
        || !visible || image_alpha <= 0 || !layer_get_visible(layer)) continue;
    var _eye = breaker_eye_light;
    _renderer.draw_soft_light(_eye.x, _eye.y, breaker_eye_halo_radius * _eye.scale,
        breaker_eye_color, breaker_eye_light_strength * image_alpha);
}
surface_reset_target();
matrix_set(matrix_world, _world);
matrix_set(matrix_view, _view);
matrix_set(matrix_projection, _projection);
draw_set_color(c_white);
draw_set_alpha(1);
gpu_set_blendmode_ext(bm_dest_colour, bm_zero);
draw_surface_stretched(light_surface, _cx, _cy, _vw, _vh);
gpu_set_blendmode(bm_normal);
// Shot centers stay bright and feed bloom extraction.
with (o_HitscanVisual)
{
    if (emissive) draw_emissive_streak();
}
// Keep the red visor bright after ambient dimming, including during transition.
with (oEnemy_Breaker)
{
    breaker_draw_eye_glow();
}
// Keep Breaker's white pressure burst readable against the dark room.
with (oBreakerSlamVFX)
{
    // Depth-spawned impacts can have no named layer; they are still visible.
    if (defer_to_lighting && visible && (layer == -1 || layer_get_visible(layer))) draw_pressure_burst();
}
// Extract bright scene pixels, blur horizontally and vertically, then add the glow.
if (bloom_enabled && (bloom_strength > 0 || scout_bloom_strength > 0 || player_bloom_strength > 0 || lava_bloom_strength > 0)
&& surface_exists(application_surface)
&& shader_is_compiled(sh_BloomExtract) && shader_is_compiled(sh_BloomBlur))
{
    var _bw = max(1, ceil(surface_get_width(application_surface) * clamp(bloom_resolution, 0.125, 1)));
    var _bh = max(1, ceil(surface_get_height(application_surface) * clamp(bloom_resolution, 0.125, 1)));
    if (surface_exists(bloom_surface_a))
    {
        if (surface_get_width(bloom_surface_a) != _bw || surface_get_height(bloom_surface_a) != _bh)
        {
            surface_free(bloom_surface_a);
            bloom_surface_a = -1;
        }
    }
    if (surface_exists(bloom_surface_b))
    {
        if (surface_get_width(bloom_surface_b) != _bw || surface_get_height(bloom_surface_b) != _bh)
        {
            surface_free(bloom_surface_b);
            bloom_surface_b = -1;
        }
    }
    if (!surface_exists(bloom_surface_a)) bloom_surface_a = surface_create(_bw, _bh);
    if (!surface_exists(bloom_surface_b)) bloom_surface_b = surface_create(_bw, _bh);
    if (surface_exists(bloom_surface_a) && surface_exists(bloom_surface_b))
    {
        // Postprocessing uses a fixed pixel grid, independent of world-camera fractions.
        if (bloom_camera == -1) bloom_camera = camera_create_view(0, 0, _bw, _bh);
        camera_set_view_size(bloom_camera, _bw, _bh);
        var _old_filter = gpu_get_texfilter();
        gpu_set_texfilter(true);
        gpu_set_blendmode_ext(bm_one, bm_zero);
        surface_set_target(bloom_surface_a);
        camera_apply(bloom_camera);
        draw_clear_alpha(c_black, 1);
        if (bloom_scene_enabled)
        {
            shader_set(sh_BloomExtract);
            shader_set_uniform_f(bloom_gain_uniform, 1);
            shader_set_uniform_f(bloom_threshold_uniform, clamp(bloom_threshold, 0, 0.99));
            draw_surface_stretched(application_surface, 0, 0, _bw, _bh);
            shader_reset();
        }
        bloom_view_x = _cx;
        bloom_view_y = _cy;
        bloom_scale_x = _bw / _vw;
        bloom_scale_y = _bh / _vh;
        // Add a wider shot source only to the bloom buffer, in screen coordinates.
        gpu_set_blendmode(bm_normal);
        with (o_HitscanVisual)
        {
            if (emissive && _renderer.hitscan_bloom_strength > 0)
            {
                draw_set_color(bullet_lightning ? make_color_rgb(65, 155, 255)
                    : (bullet_fiery ? make_color_rgb(255, 105, 15) : line_color));
                draw_set_alpha(clamp(_renderer.hitscan_bloom_strength, 0, 1));
                draw_line_width(
                    (line_x1 - _cx) * _bw / _vw, (line_y1 - _cy) * _bh / _vh,
                    (line_x2 - _cx) * _bw / _vw, (line_y2 - _cy) * _bh / _vh,
                    max(1, _renderer.hitscan_bloom_width)
                        * line_width * _bh / _vh
                );
            }
        }
        // Bloom comes from glowing sources, never from the wide illumination cones.
        gpu_set_blendmode(bm_add);
        with (o_light_ceil_long)
            _renderer.draw_lamp_bloom(id, _renderer.ceiling_light);
        with (o_light_ceil_long_strong)
            _renderer.draw_lamp_bloom(id, _renderer.ceiling_light_strong);
        with (o_light_ceil_long_ow)
            _renderer.draw_lamp_bloom(id, _renderer.ceiling_light,
                image_index < 1 ? _renderer.ceiling_flicker.dim_multiplier : 1);
        with (o_DoorController)
        if (layer_get_visible(layer))
            _renderer.draw_bloom_point((bbox_left + bbox_right) * 0.5, (bbox_top + bbox_bottom) * 0.5,
                controller_state == 0 ? _renderer.terminal_idle_color : _renderer.terminal_used_color,
                _renderer.terminal_bloom_strength);
        with (o_DemoTerminal)
        if (layer_get_visible(layer))
            _renderer.draw_bloom_point((bbox_left + bbox_right) * 0.5, (bbox_top + bbox_bottom) * 0.5,
                _renderer.demo_terminal_color, _renderer.terminal_bloom_strength);
        with (o_ShotImpact)
        {
            for (var _i = 0; _i < array_length(particles); _i++)
            {
                var _p = particles[_i];
                if (_p.dust) continue;
                var _fade = clamp(_p.life / _p.duration, 0, 1);
                var _angle = point_direction(0, 0, _p.vx, _p.vy);
                _renderer.draw_bloom_line(_p.px, _p.py,
                    _p.px - lengthdir_x(spark_tail_length * _fade, _angle),
                    _p.py - lengthdir_y(spark_tail_length * _fade, _angle),
                    spark_color_start, spark_width, _fade);
            }
        }
        with (o_Block_wires)
        {
            if (!layer_get_visible(layer)) continue;
            for (var _i = 0; _i < array_length(wire_arcs); _i++)
            {
                var _arc = wire_arcs[_i];
                _renderer.draw_bloom_point(x + _arc.anchor_x * image_xscale,
                    y + _arc.anchor_y * image_yscale, _renderer.wire_color, 0.6);
            }
        }
        draw_set_color(c_white);
        draw_set_alpha(1);
        gpu_set_blendmode_ext(bm_one, bm_zero);
        surface_reset_target();

        surface_set_target(bloom_surface_b);
        camera_apply(bloom_camera);
        draw_clear_alpha(c_black, 1);
        shader_set(sh_BloomBlur);
        shader_set_uniform_f(bloom_step_uniform, max(0, bloom_radius) * 0.5 / _vw, 0);
        draw_surface_stretched(bloom_surface_a, 0, 0, _bw, _bh);
        shader_reset();
        surface_reset_target();

        surface_set_target(bloom_surface_a);
        camera_apply(bloom_camera);
        draw_clear_alpha(c_black, 1);
        shader_set(sh_BloomBlur);
        shader_set_uniform_f(bloom_step_uniform, 0, max(0, bloom_radius) * 0.5 / _vh);
        draw_surface_stretched(bloom_surface_b, 0, 0, _bw, _bh);
        shader_reset();
        surface_reset_target();

        matrix_set(matrix_world, _world);
        matrix_set(matrix_view, _view);
        matrix_set(matrix_projection, _projection);
        gpu_set_blendmode(bm_add);
        draw_set_alpha(clamp(bloom_strength, 0, 1));
        draw_surface_stretched(bloom_surface_a, _cx, _cy, _vw, _vh);
        // Shared Scout/Drone glow: gain is applied AFTER blur, independently of scene bloom.
        if ((instance_exists(oEnemy_Scout) || instance_exists(oDrone)) && scout_bloom_strength > 0)
        {
            draw_set_alpha(1);
            draw_set_color(c_white);
            gpu_set_blendmode(bm_normal);
            surface_set_target(bloom_surface_a);
            camera_apply(bloom_camera);
            draw_clear_alpha(c_black, 1);
            shader_set(sh_BloomExtract);
            shader_set_uniform_f(bloom_gain_uniform, 1);
            shader_set_uniform_f(bloom_threshold_uniform, clamp(scout_bloom_threshold, 0, 0.99));
            gpu_set_texfilter(false);
            with (oEnemy_Scout)
            {
                var _source_x = (bbox_left + bbox_right) * 0.5
                    - scout_facing * sprite_get_width(sprite_index) * scout_scale * 0.5;
                var _source_y = bbox_bottom + 1 - sprite_get_height(sprite_index) * scout_scale;
                draw_sprite_ext(sprite_index, image_index,
                    (_source_x - _renderer.bloom_view_x) * _renderer.bloom_scale_x,
                    (_source_y - _renderer.bloom_view_y) * _renderer.bloom_scale_y,
                    scout_facing * scout_scale * _renderer.bloom_scale_x,
                    scout_scale * _renderer.bloom_scale_y,
                    image_angle, image_blend,
                    image_alpha);
            }
            with (oDrone)
            {
                // Match the sprite pose drawn by oEnemyParent, including attack shake.
                draw_sprite_ext(sprite_index, image_index,
                    (x + attack_shake_x - _renderer.bloom_view_x) * _renderer.bloom_scale_x,
                    (y + attack_shake_y - _renderer.bloom_view_y) * _renderer.bloom_scale_y,
                    image_xscale * _renderer.bloom_scale_x,
                    image_yscale * _renderer.bloom_scale_y,
                    image_angle, image_blend,
                    image_alpha);
            }
            gpu_set_texfilter(true);
            shader_reset();
            surface_reset_target();

            gpu_set_blendmode_ext(bm_one, bm_zero);
            surface_set_target(bloom_surface_b);
            camera_apply(bloom_camera);
            draw_clear_alpha(c_black, 1);
            shader_set(sh_BloomBlur);
            shader_set_uniform_f(bloom_step_uniform, max(0, scout_bloom_radius) * 0.5 / _vw, 0);
            draw_surface_stretched(bloom_surface_a, 0, 0, _bw, _bh);
            shader_reset();
            surface_reset_target();

            surface_set_target(bloom_surface_a);
            camera_apply(bloom_camera);
            draw_clear_alpha(c_black, 1);
            shader_set(sh_BloomBlur);
            shader_set_uniform_f(bloom_step_uniform, 0, max(0, scout_bloom_radius) * 0.5 / _vh);
            draw_surface_stretched(bloom_surface_b, 0, 0, _bw, _bh);
            shader_reset();
            surface_reset_target();

            matrix_set(matrix_world, _world);
            matrix_set(matrix_view, _view);
            matrix_set(matrix_projection, _projection);
            gpu_set_blendmode(bm_add);
            draw_set_alpha(1);
            shader_set(sh_BloomExtract);
            // All pixels pass; this draw only applies unclamped RGB gain.
            shader_set_uniform_f(bloom_threshold_uniform, -1);
            shader_set_uniform_f(bloom_gain_uniform, max(0, scout_bloom_strength));
            draw_surface_stretched(bloom_surface_a, _cx, _cy, _vw, _vh);
            shader_reset();
        }
        // Select cyan pixels from the exact head/IK rig pose drawn in the world.
        if (instance_exists(o_Player) && player_bloom_strength > 0
        && shader_is_compiled(sh_PlayerGlowExtract))
        {
            draw_set_alpha(1);
            draw_set_color(c_white);
            gpu_set_blendmode(bm_normal);
            surface_set_target(bloom_surface_a);
            camera_apply(bloom_camera);
            draw_clear_alpha(c_black, 1);
            // Use the world camera because the player Draw event uses room coordinates.
            camera_apply(_cam);
            shader_set(sh_PlayerGlowExtract);
            shader_set_uniform_f(player_glow_color_uniform,
                color_get_red(player_bloom_color) / 255,
                color_get_green(player_bloom_color) / 255,
                color_get_blue(player_bloom_color) / 255);
            shader_set_uniform_f(player_glow_tolerance_uniform, max(0, player_bloom_tolerance));
            shader_set_uniform_f(player_glow_feather_uniform, max(0.001, player_bloom_feather));
            shader_set_uniform_f(player_glow_brightness_uniform, clamp(player_bloom_min_brightness, 0, 0.99));
            gpu_set_texfilter(false);
            with (o_Player)
            {
                // Draw_0 only calculates and renders the pose; it advances no gameplay state.
                if (visible) event_perform(ev_draw, 0);
            }
            gpu_set_texfilter(true);
            shader_reset();
            surface_reset_target();

            gpu_set_blendmode_ext(bm_one, bm_zero);
            surface_set_target(bloom_surface_b);
            camera_apply(bloom_camera);
            draw_clear_alpha(c_black, 1);
            shader_set(sh_BloomBlur);
            shader_set_uniform_f(bloom_step_uniform, max(0, player_bloom_radius) * 0.5 / _vw, 0);
            draw_surface_stretched(bloom_surface_a, 0, 0, _bw, _bh);
            shader_reset();
            surface_reset_target();

            surface_set_target(bloom_surface_a);
            camera_apply(bloom_camera);
            draw_clear_alpha(c_black, 1);
            shader_set(sh_BloomBlur);
            shader_set_uniform_f(bloom_step_uniform, 0, max(0, player_bloom_radius) * 0.5 / _vh);
            draw_surface_stretched(bloom_surface_b, 0, 0, _bw, _bh);
            shader_reset();
            surface_reset_target();

            matrix_set(matrix_world, _world);
            matrix_set(matrix_view, _view);
            matrix_set(matrix_projection, _projection);
            gpu_set_blendmode(bm_add);
            draw_set_alpha(1);
            shader_set(sh_BloomExtract);
            // All pixels pass; this draw only applies unclamped RGB gain.
            shader_set_uniform_f(bloom_threshold_uniform, -1);
            shader_set_uniform_f(bloom_gain_uniform, max(0, player_bloom_strength));
            draw_surface_stretched(bloom_surface_a, _cx, _cy, _vw, _vh);
            shader_reset();
        }
        // Reuse the bloom buffers for a separate, stronger lava-only glow.
        if (instance_exists(oLavaFromTheMolten) && lava_bloom_strength > 0)
        {
            draw_set_alpha(1);
            draw_set_color(c_white);
            gpu_set_blendmode(bm_normal);
            surface_set_target(bloom_surface_a);
            camera_apply(_cam);
            draw_clear_alpha(c_black, 1);
            with (oLavaFromTheMolten)
            {
                if (visible && layer_get_visible(layer) && sprite_index != -1 && image_alpha > 0)
                {
                    draw_sprite_ext(sprite_index, image_index, x, y,
                        image_xscale, image_yscale, image_angle, image_blend, image_alpha);
                }
            }
            // Covered lava must not generate a halo outside the cover.
            draw_lava_bloom_occluder();
            surface_reset_target();

            gpu_set_blendmode_ext(bm_one, bm_zero);
            surface_set_target(bloom_surface_b);
            camera_apply(bloom_camera);
            draw_clear_alpha(c_black, 1);
            shader_set(sh_BloomBlur);
            shader_set_uniform_f(bloom_step_uniform, max(0, lava_bloom_radius) * 0.5 / _vw, 0);
            draw_surface_stretched(bloom_surface_a, 0, 0, _bw, _bh);
            shader_reset();
            surface_reset_target();

            surface_set_target(bloom_surface_a);
            camera_apply(bloom_camera);
            draw_clear_alpha(c_black, 1);
            shader_set(sh_BloomBlur);
            shader_set_uniform_f(bloom_step_uniform, 0, max(0, lava_bloom_radius) * 0.5 / _vh);
            draw_surface_stretched(bloom_surface_b, 0, 0, _bw, _bh);
            shader_reset();
            // Clip blur spill as well, respecting the cover's live visibility and alpha.
            gpu_set_blendmode(bm_normal);
            camera_apply(_cam);
            draw_lava_bloom_occluder();
            surface_reset_target();

            matrix_set(matrix_world, _world);
            matrix_set(matrix_view, _view);
            matrix_set(matrix_projection, _projection);
            gpu_set_blendmode(bm_add);
            draw_set_alpha(clamp(lava_bloom_strength, 0, 1));
            draw_surface_stretched(bloom_surface_a, _cx, _cy, _vw, _vh);
        }
        gpu_set_blendmode(bm_normal);
        gpu_set_texfilter(_old_filter);
    }
}
// Final world pass runs after bloom and before Draw GUI, keeping the HUD sharp.
if (pixelation_enabled && pixelation_size > 1 && surface_exists(application_surface)
&& shader_is_compiled(sh_WorldPixelate))
{
    var _pw = surface_get_width(application_surface);
    var _ph = surface_get_height(application_surface);
    if (surface_exists(pixelation_surface))
    {
        if (surface_get_width(pixelation_surface) != _pw || surface_get_height(pixelation_surface) != _ph)
        {
            surface_free(pixelation_surface);
            pixelation_surface = -1;
        }
    }
    if (!surface_exists(pixelation_surface)) pixelation_surface = surface_create(_pw, _ph);
    if (surface_exists(pixelation_surface))
    {
        if (pixelation_camera == -1) pixelation_camera = camera_create_view(0, 0, _pw, _ph);
        camera_set_view_size(pixelation_camera, _pw, _ph);
        var _pixel_filter = gpu_get_texfilter();
        gpu_set_texfilter(false);
        gpu_set_blendmode_ext(bm_one, bm_zero);
        draw_set_color(c_white);
        draw_set_alpha(1);
        surface_set_target(pixelation_surface);
        camera_apply(pixelation_camera);
        shader_set(sh_WorldPixelate);
        shader_set_uniform_f(pixelation_grid_uniform,
            max(1, _vw / pixelation_size), max(1, _vh / pixelation_size));
        shader_set_uniform_f(pixelation_texel_uniform, 1 / _pw, 1 / _ph);
        draw_surface_stretched(application_surface, 0, 0, _pw, _ph);
        shader_reset();
        surface_reset_target();
        matrix_set(matrix_world, _world);
        matrix_set(matrix_view, _view);
        matrix_set(matrix_projection, _projection);
        draw_surface_stretched(pixelation_surface, _cx, _cy, _vw, _vh);
        gpu_set_blendmode(bm_normal);
        gpu_set_texfilter(_pixel_filter);
    }
}
draw_set_color(_old_color);
draw_set_alpha(_old_alpha);
