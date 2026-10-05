var old_colour = draw_get_color();
var old_alpha = draw_get_alpha();

var progress = clamp(fx_age / fx_duration, 0, 1);
var expansion = 1 - power(1 - progress, 3);
var radius = lerp(4, fx_radius, expansion);
var opacity = power(1 - progress, 2);
var ring_y = y - 2;

// Brief white flash at the centre.
if (progress < 0.25)
{
    var flash_alpha = 0.65 * (1 - progress / 0.25);
    var flash_width = min(36, fx_radius * 0.45) * (1 + progress);
    draw_set_color(fx_colour_flash);
    draw_set_alpha(flash_alpha);
    draw_ellipse(
        x - flash_width, ring_y - flash_width * 0.3,
        x + flash_width, ring_y + flash_width * 0.3,
        false
    );
}

// Two expanding elliptical rings on the ground.
// Line segments let us set ring thickness without a sprite or shader.
var segments = 48;
for (var ring = 0; ring < 2; ring++)
{
    var ring_radius = radius * (ring == 0 ? 1 : 0.72);
    var ring_alpha = opacity * (ring == 0 ? 0.9 : 0.45);
    var ring_width = fx_ring_width * (ring == 0 ? 1 : 0.65);

    draw_set_color(ring == 0 ? fx_colour : fx_colour_secondary);
    draw_set_alpha(ring_alpha);

    for (var segment = 0; segment < segments; segment++)
    {
        var angle_a = segment * 360 / segments;
        var angle_b = (segment + 1) * 360 / segments;

        draw_line_width(
            x + lengthdir_x(ring_radius, angle_a),
            ring_y + lengthdir_y(ring_radius * fx_ring_flatness, angle_a),
            x + lengthdir_x(ring_radius, angle_b),
            ring_y + lengthdir_y(ring_radius * fx_ring_flatness, angle_b),
            ring_width
        );
    }
}

// Sparks fly upward and fade into short streaks.
for (var i = 0; i < array_length(fx_sparks); i++)
{
    var spark = fx_sparks[i];
    var spark_alpha = clamp(spark.life / spark.max_life, 0, 1);
    var streak_x = clamp(spark.vx * 0.018, -18, 18);
    var streak_y = clamp(spark.vy * 0.018, -18, 18);

    draw_set_color(spark.colour);
    draw_set_alpha(spark_alpha);
    draw_line_width(
        spark.px, spark.py,
        spark.px - streak_x, spark.py - streak_y,
        spark.width
    );
}

draw_set_color(old_colour);
draw_set_alpha(old_alpha);