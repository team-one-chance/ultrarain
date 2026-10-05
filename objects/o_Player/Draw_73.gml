// =====================================
// SPARK SETTINGS
// =====================================

var spark_size = 1.0;
var spark_quantity = 100;
var spark_spread = 1.0;   // 0.5 = central area, 1 = whole mask
var spark_opacity = 1.0;
var spark_flight_distance = 1.2;

var spark_color_1change = make_color_rgb(90, 220, 255);
var spark_color2change = make_color_rgb(53, 40, 193);

var spark_color_1 = spark_color_1change;
var spark_color2 = spark_color2change;


// =====================================
// INITIALISE
// =====================================

if (!variable_instance_exists(id, "damage_sparks"))
{
    damage_sparks = [];
    previous_spark_hp = pHP;
}


// =====================================
// CREATE SPARKS WHEN HP DROPS
// =====================================

if (pHP < previous_spark_hp)
{
    var centre_x = (bbox_left + bbox_right) / 2;
    var centre_y = (bbox_top + bbox_bottom) / 2;
    var area = clamp(spark_spread, 0, 1);

    var spawn_left = lerp(centre_x, bbox_left, area);
    var spawn_right = lerp(centre_x, bbox_right, area);
    var spawn_top = lerp(centre_y, bbox_top, area);
    var spawn_bottom = lerp(centre_y, bbox_bottom, area);

    for (var n = 0; n < spark_quantity; n++)
    {
        var spawn_x = centre_x;
        var spawn_y = centre_y;
        var found_point = false;

        // Try random positions until one touches this player's mask.
        for (var attempt = 0; attempt < 32; attempt++)
        {
            var test_x = random_range(spawn_left, spawn_right);
            var test_y = random_range(spawn_top, spawn_bottom);

            if (collision_point(test_x, test_y, id, true, false) == id)
            {
                spawn_x = test_x;
                spawn_y = test_y;
                found_point = true;
                break;
            }
        }

        if (!found_point)
        {
            continue;
        }

        var angle = random(360);
        var speed1 = random_range(90, 220)
            * spark_flight_distance;
        var lifetime = random_range(0.18, 0.38);

        array_push(damage_sparks, {
            x: spawn_x,
            y: spawn_y,
            vx: lengthdir_x(speed1, angle),
            vy: lengthdir_y(speed1, angle),
            life: lifetime,
            max_life: lifetime,
            colour: (n < round(spark_quantity * 0.25))
                ? spark_color_1
                : spark_color2
        });
    }
}

previous_spark_hp = pHP;


// =====================================
// MOVE AND DRAW SPARKS
// =====================================

var dt = min(delta_time / 1000000, 0.05);
var old_colour = draw_get_color();
var old_alpha = draw_get_alpha();

for (var i = array_length(damage_sparks) - 1; i >= 0; i--)
{
    var spark = damage_sparks[i];

    spark.life -= dt;

    if (spark.life <= 0)
    {
        array_delete(damage_sparks, i, 1);
        continue;
    }

    spark.x += spark.vx * dt;
    spark.y += spark.vy * dt;
    spark.vy += 300 * dt;

    draw_set_color(spark.colour);
    draw_set_alpha(
        clamp(spark_opacity, 0, 1)
        * spark.life / spark.max_life
    );

    draw_line_width(
        spark.x,
        spark.y,
        spark.x - spark.vx * 0.025 * spark_size,
        spark.y - spark.vy * 0.025 * spark_size,
        2 * spark_size
    );
}

draw_set_color(old_colour);
draw_set_alpha(old_alpha);