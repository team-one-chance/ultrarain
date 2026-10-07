var fx_dt = delta_time / 1000000;
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
    spark.vy += 220 * fx_dt;
}

for (var i = 0; i < array_length(fx_debris); i++)
{
    var piece = fx_debris[i];
    piece.px += piece.vx * fx_dt;
    piece.py += piece.vy * fx_dt;
    piece.vy += 430 * fx_dt;
    piece.angle += piece.spin * fx_dt;
}
