// Slash tuning lives here; the player supplies only the owner and swing direction.
slash_damage = 10; // HP removed per enemy per slash; higher values deal more damage.
global.GLslash_damage = slash_damage
knockback_force = 50; // Force passed to enemy.take_damage; higher values push harder.
global.GLknockback_force = knockback_force // Force passed to enemy.take_damage; higher values push harder.
slash_forward = 80; // Pixels ahead of the player; higher values extend the slash reach.
slash_down = 0; // Pixels below the player origin; positive values lower the slash.
slash_scale = 1; // Multiplier for slash art and hitbox size.
duration = 0.24; // Seconds for standalone playback; owned slashes follow the player's strike phase.
slash_age = 0;
slash_animation_finished = false;
// One-shot animation controlled by elapsed time, not sprite auto-looping.
image_speed = 0;
image_index = 0;
slash_owner = noone;
slash_can_damage = true;

sync_sword_swing = function()
{
    if (!instance_exists(slash_owner))
    {
        instance_destroy();
        return false;
    }

    var config = slash_owner.sword_config;
    var progress = 1 - slash_owner.sword_swing_timer / max(0.001, config.swing_duration);
    var strike_start = clamp(config.windup_phase, 0.001, 0.998);
    var strike_end = clamp(config.follow_through_phase, strike_start + 0.001, 0.999);
    if (slash_owner.weapon_type != "sword"
    || slash_owner.sword_swing_timer <= 0 || progress >= strike_end)
    {
        instance_destroy();
        return false;
    }

    var strike_progress = clamp((progress - strike_start) / (strike_end - strike_start), 0, 1);
    image_index = min(image_number - 1, floor(strike_progress * image_number));
    image_xscale = slash_owner.sword_swing_facing * slash_scale;
    image_yscale = slash_scale;
    x = slash_owner.x + slash_forward * slash_owner.sword_swing_facing;
    y = slash_owner.y + slash_down;
    slash_can_damage = progress >= clamp(config.hit_phase, 0, 1);
    return true;
};

// Each enemy takes damage once per slash.
hit_enemies = ds_list_create();

// Each slash can release only one coin-powered beam.
coin_beam_released = false;
