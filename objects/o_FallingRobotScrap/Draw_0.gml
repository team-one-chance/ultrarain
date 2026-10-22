// Render the rotated sprite into a small transparent buffer, then crop it.
if (keyboard_check_pressed(vk_f8))
{
    var _lava = instance_nearest(x, y, oMoltenLava);
    var _lava_front = instance_nearest(x, y, oLavaFromTheMolten);

    show_debug_message(
        "SCRAP DRAW"
        + " | state=" + string(scrap_state)
        + " | depth=" + string(depth)
        + " | normal=" + string(scrap_normal_depth)
    );

    if (instance_exists(_lava))
    {
        show_debug_message(
            "LAVA depth=" + string(_lava.depth)
        );
    }

    if (instance_exists(_lava_front))
    {
        show_debug_message(
            "LAVA FRONT depth=" + string(_lava_front.depth)
        );
    }
}
// This retains its rotation while the lava progressively hides the body.
if (!surface_exists(scrap_surface)) scrap_surface = surface_create(128, 128);
if (!surface_exists(scrap_surface)) exit;
if (scrap_draw_camera == -1)
    scrap_draw_camera = camera_create_view(0, 0, 128, 128);

var _world = matrix_get(matrix_world);
var _view = matrix_get(matrix_view);
var _projection = matrix_get(matrix_projection);
var _old_alpha = draw_get_alpha();
var _old_color = draw_get_color();

surface_set_target(scrap_surface);
camera_apply(scrap_draw_camera);
matrix_set(matrix_world, matrix_build_identity());
draw_clear_alpha(c_black, 0);
draw_set_alpha(1);
draw_set_color(c_white);
draw_sprite_ext(scrap_draw_sprite, scrap_variant, 64, 64,
    image_xscale, image_yscale, scrap_draw_angle, image_blend, 1);
surface_reset_target();
matrix_set(matrix_world, _world);
matrix_set(matrix_view, _view);
matrix_set(matrix_projection, _projection);

var _top = 0;
var _bottom = 128;
if (scrap_state == 0 && !scrap_emerged)
    _top = clamp(ceil(scrap_release_y - (y - 64)), 0, 128);
if (scrap_state == 3)
    _bottom = clamp(floor(scrap_lava_y - (y - 64)), 0, 128);

draw_set_alpha(1);
draw_set_color(c_white);
if (_bottom > _top)
{
    draw_surface_part(scrap_surface, 0, _top, 128, _bottom - _top,
        x - 64, y - 64 + _top);
}

for (var _i = 0; _i < array_length(scrap_sparks); _i++)
{
    var _spark = scrap_sparks[_i];
    draw_set_alpha(clamp(_spark.life / 0.12, 0, 1));
    draw_set_color(_spark.color);
    draw_line_width(round(_spark.x), round(_spark.y),
        round(_spark.x - _spark.vx * 0.025),
        round(_spark.y - _spark.vy * 0.025), 1);
}
draw_set_alpha(_old_alpha);
draw_set_color(_old_color);
