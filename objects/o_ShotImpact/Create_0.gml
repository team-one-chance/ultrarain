// Impact tuning: pixels/second and seconds.
if (!variable_instance_exists(id, "impact_parry")) impact_parry = false;
parry_ring_duration = 0.30;
parry_ring_life = impact_parry ? parry_ring_duration : 0;
parry_ring_radius = 44;
spark_count = 8;
spark_spread = 75;
spark_speed_min = 65;
spark_speed_max = 145;
spark_lifetime_min = 0.12;
spark_lifetime_max = 0.24;
spark_gravity = 160;
spark_tail_length = 6;
dust_count = 3;
dust_lifetime = 0.20;
if (!variable_instance_exists(id, "impact_direction")) impact_direction = 0;
if (!variable_instance_exists(id, "impact_enemy")) impact_enemy = false;
spark_width = 1;
spark_color_start = make_color_rgb(255, 245, 215);
spark_color_end = make_color_rgb(190, 170, 130);
flash_duration = 0;
flash_radius = 0;

// Enemy impact tuning: a wider, brighter burst with a brief contact flash.
if (impact_enemy)
{
    spark_count = 16;
    spark_spread = 130;
    spark_speed_min = 100;
    spark_speed_max = 230;
    spark_lifetime_min = 0.12;
    spark_lifetime_max = 0.28;
    spark_tail_length = 12;
    spark_width = 1;
    spark_color_start = c_white;
    spark_color_end = make_color_rgb(225, 175, 95);
    dust_count = 3;
    flash_duration = 0.045;
    flash_radius = 4;
}
// Sekiro-inspired deflection: a crisp expanding gold ring and radial sparks.
if (impact_parry)
{
    spark_count = 28;
    spark_spread = 180;
    spark_speed_min = 130;
    spark_speed_max = 310;
    spark_lifetime_min = 0.16;
    spark_lifetime_max = 0.36;
    spark_tail_length = 14;
    spark_gravity = 210;
    spark_color_start = make_color_rgb(255, 240, 185);
    spark_color_end = make_color_rgb(255, 105, 20);
    dust_count = 0;
    flash_duration = 0.055;
    flash_radius = 7;
}
flash_life = flash_duration;
particles = [];
for (var _i = 0; _i < max(0, floor(spark_count)) + max(0, floor(dust_count)); _i++)
{
    var _dust = _i >= max(0, floor(spark_count));
    var _angle = impact_direction + 180 + random_range(-spark_spread, spark_spread);
    var _speed = _dust ? random_range(10, 25) : random_range(spark_speed_min, spark_speed_max);
    var _life = _dust ? dust_lifetime : random_range(spark_lifetime_min, spark_lifetime_max);
    array_push(particles, { px: x, py: y,
        vx: lengthdir_x(_speed, _angle), vy: lengthdir_y(_speed, _angle),
        life: _life, duration: _life, dust: _dust });
}
