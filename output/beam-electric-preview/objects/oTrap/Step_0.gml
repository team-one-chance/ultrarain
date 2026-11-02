var dt = (variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000;
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

if (player != noone
&& trap_hit_timer <= 0
&& player.take_damage(trap_damage, x))
{
    trap_hit_timer = trap_hit_cooldown;

player.trap_bounce_speed = trap_bounce_speed;
player.trap_bounce_pending = true;
}
