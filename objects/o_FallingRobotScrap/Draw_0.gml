var _hidden = (scrap_state == 0 && !scrap_emerged)
    ? clamp(ceil((scrap_release_y - (y - 24 * scrap_size)) / scrap_size), 0, 48)
    : 0;
if (_hidden > 0) {
    // Reveal the robot below the hatch instead of popping in its entire body.
    if (_hidden < 48) {
        draw_sprite_part_ext(scrap_draw_sprite, scrap_variant, 0, _hidden, 48, 48 - _hidden,
            x - 24 * image_xscale, y - 24 * scrap_size + _hidden * scrap_size,
            image_xscale, image_yscale, image_blend, image_alpha);
    }
} else {
    draw_sprite_ext(scrap_draw_sprite, scrap_variant, x, y,
        image_xscale, image_yscale, image_angle, image_blend, image_alpha);
}
var _old_alpha = draw_get_alpha();
var _old_color = draw_get_color();
for (var _i = 0; _i < array_length(scrap_sparks); _i++) {
    var _spark = scrap_sparks[_i];
    if (_spark.life <= 0) continue;
    draw_set_alpha(clamp(_spark.life / 0.12, 0, 1));
    draw_set_color(_spark.color);
    draw_line_width(round(_spark.x), round(_spark.y),
        round(_spark.x - _spark.vx * 0.025),
        round(_spark.y - _spark.vy * 0.025), 1);
}
draw_set_alpha(_old_alpha);
draw_set_color(_old_color);
