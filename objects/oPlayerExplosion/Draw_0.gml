var old_colour = draw_get_color();
var old_alpha = draw_get_alpha();

// Fast fireball and shockwave, followed by lingering debris.
var burst = clamp(fx_age / 0.3, 0, 1);
var radius = lerp(5, fx_radius, 1 - power(1 - burst, 3));
if (burst < 1)
{
    draw_set_color(make_color_rgb(255, 100, 20));
    draw_set_alpha(0.7 * power(1 - burst, 2));
    draw_circle(x, y, radius * 0.7, false);
    draw_set_color(c_yellow);
    draw_set_alpha(0.9 * (1 - burst));
    for (var i = 0; i < 40; i++)
    {
        var a = i * 9;
        draw_line_width(
            x + lengthdir_x(radius, a), y + lengthdir_y(radius, a),
            x + lengthdir_x(radius, a + 9), y + lengthdir_y(radius, a + 9),
            2 * (1 - burst) + 0.5
        );
    }
}
if (fx_age < 0.08)
{
    draw_set_color(c_white);
    draw_set_alpha(1 - fx_age / 0.08);
    draw_circle(x, y, 18 + fx_age * 120, false);
}

for (var i = 0; i < array_length(fx_sparks); i++)
{
    var spark = fx_sparks[i];
    draw_set_color(spark.colour);
    draw_set_alpha(clamp(spark.life / spark.max_life, 0, 1));
    draw_line_width(
        spark.px, spark.py,
        spark.px - spark.vx * 0.025, spark.py - spark.vy * 0.025,
        1.5
    );
}

draw_set_alpha(clamp((fx_duration - fx_age) / 0.3, 0, 1));
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
