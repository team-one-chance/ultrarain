var old_colour = draw_get_color();
var old_alpha = draw_get_alpha();

// A compact flash and ring, followed by a few sparks and metal fragments.
var burst = clamp(fx_age / 0.22, 0, 1);
var radius = lerp(3, fx_radius, 1 - power(1 - burst, 3));
if (burst < 1)
{
    draw_set_color(make_color_rgb(255, 100, 20));
    draw_set_alpha(0.55 * power(1 - burst, 2));
    draw_circle(x, y, radius * 0.7, false);
    draw_set_color(c_yellow);
    draw_set_alpha(0.7 * (1 - burst));
    for (var i = 0; i < 24; i++)
    {
        var a = i * 15;
        draw_line_width(
            x + lengthdir_x(radius, a), y + lengthdir_y(radius, a),
            x + lengthdir_x(radius, a + 15), y + lengthdir_y(radius, a + 15),
            1.2 * (1 - burst) + 0.5
        );
    }
}
if (fx_age < 0.055)
{
    draw_set_color(c_white);
    draw_set_alpha(0.8 * (1 - fx_age / 0.055));
    draw_circle(x, y, 10 + fx_age * 60, false);
}

for (var i = 0; i < array_length(fx_sparks); i++)
{
    var spark = fx_sparks[i];
    draw_set_color(spark.colour);
    draw_set_alpha(clamp(spark.life / spark.max_life, 0, 1));
    draw_line_width(
        spark.px, spark.py,
        spark.px - spark.vx * 0.018, spark.py - spark.vy * 0.018,
        1
    );
}

draw_set_alpha(clamp((fx_duration - fx_age) / 0.22, 0, 1));
for (var i = 0; i < array_length(fx_debris); i++)
{
    var piece = fx_debris[i];
    var dx = lengthdir_x(piece.size, piece.angle);
    var dy = lengthdir_y(piece.size, piece.angle);
    var side_x = lengthdir_x(piece.size * 0.5, piece.angle + 90);
    var side_y = lengthdir_y(piece.size * 0.5, piece.angle + 90);
    draw_set_color(piece.colour);
    draw_triangle(
        piece.px + dx, piece.py + dy,
        piece.px - dx + side_x, piece.py - dy + side_y,
        piece.px - dx - side_x, piece.py - dy - side_y,
        false
    );
}

draw_set_color(old_colour);
draw_set_alpha(old_alpha);
