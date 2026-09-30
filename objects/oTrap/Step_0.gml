var dt = delta_time / 1000000;
trap_hit_timer = max(0, trap_hit_timer - dt);

var player = collision_rectangle(
    bbox_left,
    bbox_top,
    bbox_right,
    bbox_bottom,
    o_Player,
    false,
    true
);

if (player != noone && trap_hit_timer <= 0)
{
    player.pHP -= trap_damage;
    trap_hit_timer = trap_hit_cooldown;

   player.trap_knockback_speed_x = clamp(
    player.phy_speed_x * trap_horizontal_retention,
    -trap_horizontal_speed_limit,
    trap_horizontal_speed_limit
);

player.trap_bounce_speed = trap_bounce_speed;
player.trap_bounce_pending = true;
player.trap_knockback_timer = trap_knockback_duration;
}