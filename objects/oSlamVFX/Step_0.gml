var fx_dt = (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) / 1000000;
fx_age += fx_dt;

if (fx_age >= fx_duration)
{
    instance_destroy();
    exit;
}

for (var i = array_length(fx_sparks) - 1; i >= 0; i--)
{
    var spark = fx_sparks[i];
    spark.life -= fx_dt;

    if (spark.life <= 0)
    {
        array_delete(fx_sparks, i, 1);
        continue;
    }

    spark.px += spark.vx * fx_dt;
    spark.py += spark.vy * fx_dt;
    spark.vy += 650 * fx_dt;

    // Decorative bounce at the impact floor; no gameplay collisions.
    if (spark.py > y - 2 && spark.vy > 0)
    {
        spark.py = y - 2;
        spark.vy *= -0.25;
        spark.vx *= 0.7;
    }
}