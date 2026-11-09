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
// Sword deflections reuse the bounded particle burst with a cyan-white contact flash.
if (variable_instance_exists(id, "impact_sword") && impact_sword)
{
    spark_count = 20; // Fixed cap keeps confirmed contacts inexpensive.
    spark_spread = 65; // Degrees either side of the incoming contact direction.
    spark_color_start = c_white;
    spark_color_end = make_color_rgb(70, 215, 255);
    flash_radius = 10 * impact_strength; // Pixels; set by the player's shared visual tuning.
    parry_ring_radius = 30 * impact_strength;
    parry_ring_duration = 0.14;
    parry_ring_life = parry_ring_duration;
}
// Compact yellow block contact: no ring and a short, bounded spark burst.
if (variable_instance_exists(id, "impact_block") && impact_block)
{
    spark_count = 10; // Particle cap; fewer sparks keep the defensive contact readable.
    spark_spread = 65; // Degrees; a directional contact burst rather than a radial explosion.
    spark_speed_min = 65;
    spark_speed_max = 150; // Pixels/second; keep sparks close to the blocking blade.
    spark_lifetime_min = 0.07;
    spark_lifetime_max = 0.14; // Seconds; clear the contact quickly.
    spark_tail_length = 6; // Pixels; compact streaks match the short guard movement.
    parry_ring_life = 0;
    flash_duration = 2 / 60; // Seconds of localized contact flash.
    flash_radius = 7 * impact_strength;
}
// Player-owned tuning applies before allocating particles; legacy impacts keep their defaults.
impact_energy = variable_instance_exists(id, "impact_visual");
impact_gold = variable_instance_exists(id, "impact_block") && impact_block;
energy_rays = [];
energy_fragments = [];
if (impact_energy)
{
    var _v = impact_visual;
    spark_count = clamp(floor(_v.spark_count), 0, 40);
    spark_spread = impact_gold ? 85 : 70;
    spark_speed_min = _v.spark_speed_min;
    spark_speed_max = _v.spark_speed_max;
    spark_lifetime_min = _v.spark_life_min;
    spark_lifetime_max = _v.spark_life_max;
    spark_tail_length = impact_gold ? 13 : 18;
    flash_duration = _v.flash_duration;
    flash_radius = _v.flash_size * impact_strength;
    parry_ring_duration = _v.ring_duration;
    parry_ring_life = parry_ring_duration;
    parry_ring_radius = _v.ring_radius * impact_strength;
    spark_color_start = c_white;
    spark_color_end = impact_gold ? make_color_rgb(255, 190, 20) : make_color_rgb(40, 220, 255);
    for (var _ray = 0; _ray < clamp(floor(_v.streak_count), 0, 16); ++_ray)
    {
        array_push(energy_rays, { angle: _ray * 360 / max(1, _v.streak_count) + random_range(-9, 9),
            reach: random_range(0.65, 1.15) * parry_ring_radius });
    }
    for (var _fragment = 0; _fragment < clamp(floor(_v.fragment_count), 0, 12); ++_fragment)
    {
        var _dir = random(360);
        var _speed = random_range(90, 220);
        array_push(energy_fragments, { px: x, py: y, vx: lengthdir_x(_speed, _dir),
            vy: lengthdir_y(_speed, _dir), angle: _dir, life: 0.18, duration: 0.18 });
    }
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
