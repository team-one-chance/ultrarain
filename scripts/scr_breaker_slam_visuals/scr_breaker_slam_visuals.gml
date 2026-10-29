/// Shared Breaker visual and attack timing settings for TESTING and every gameplay room.
/// The slam particle and pressure-burst visual effect has been removed.
function breaker_slam_visual_settings()
{
    // Initialize once per game; runtime tuning survives room changes.
    if (!variable_global_exists("breaker_slam_visuals"))
    {
        global.breaker_slam_visuals = {
            camera_shake_pixels: 2, // Maximum camera displacement per axis in room pixels; zero disables shake.
            camera_shake_seconds: 0.16, // Shake lifetime in seconds; larger values make the impact rumble longer.
            stun_stars: {
                head_gap_pixels: 22, // Room pixels above the head or collision box; larger values raise the orbit.
                orbit_width_pixels: 11, // Sprite pixels before scaling; larger values widen the orbit.
                orbit_height_pixels: 3, // Sprite pixels before scaling; larger values make the orbit taller.
                radius_pixels: 2.8, // Sprite pixels before scaling; larger values make the stars bigger.
                orbit_degrees_per_second: 240, // Orbit speed in degrees per second; larger values spin faster.
                rotation_degrees_per_second: 90, // Star rotation speed in degrees per second; larger values spin faster.
                fade_seconds: 0.15 // Seconds remaining when the stars begin to fade; larger values fade earlier.
            },
            half_parry_sparks: {
                bright_color: make_color_rgb(255, 255, 130), // Bright yellow at the start of each spark.
                fade_color: make_color_rgb(255, 190, 0), // Gold as each spark fades.
                flash_radius_pixels: 7 // Room pixels; larger values make the contact flash wider.
            },
            attack: {
                eye_idle_color: make_color_rgb(255, 18, 24), // Red glow outside attack windows.
                full_color: c_lime, // Green shield bash: prevents damage, removes 5% of max shield HP, stuns for 1 second, and never heals.
                block_color: c_yellow, // Yellow unshielded melee: prevents damage but pushes the player back, without healing or stun.
                evade_color: c_red, // Red slam: evade; parrying gives no reduction.
                eye_halo_radius: 14, // Sprite pixels before scaling; smaller values keep the outer glow closer to the visor.
                eye_core_halo_radius: 4, // Sprite pixels before scaling; smaller values tighten the bright inner halo.
                eye_core_radius: 0.90, // Sprite pixels around the visor axis; replaces the actual eye pixels, including white damage flashes.
                eye_halo_segments: 24, // Circle subdivisions; higher values smooth the color-preserving halo edge.
                melee_warning_fraction: 0.50, // Split each complete parry-window evenly: first half warns, second half allows parrying until impact.
                shielded_contact_frame: 9, // Human frame number (1-based); shield bash lands and its parry-window ends when this frame begins.
                unshielded_contact_frame: 10, // Human frame number (1-based); damage lands and the parry-window ends at the start of frame 10, after frame 9.
                melee_blink_period: 0.08, // Seconds per green/yellow blink at attack speed 1; automatically scales with breaker_attack_speed.
                melee_blink_duty: 0.50, // Fraction of each melee warning blink spent on, 0-1.
                melee_glow_scale: 1.80, // Eye-halo radius multiplier during either melee parry window; larger values spread farther.
                melee_glow_gain: 1.60, // Halo brightness multiplier during either melee parry window; larger values shine brighter.
                warning_seconds: 0.50, // Slam warning duration in seconds; melee speed is controlled separately in Breaker's Create event.
                warning_blink_period: 0.18, // Seconds per warning blink; lower values blink faster.
                warning_blink_duty: 0.55, // Fraction of each warning blink spent on, 0-1.
                warning_glow_minimum: 0.15, // Eye glow between warning blinks, 0-1; lower values increase contrast.
                melee_base_windup_seconds: 0.61 // Baseline anticipation seconds at attack speed 1; use breaker_attack_speed in Create to scale the entire melee animation.
            }
        };
    }
    return global.breaker_slam_visuals;
}

/// Attack cues use the same configuration as the landing camera.
function breaker_attack_settings()
{
    return breaker_slam_visual_settings().attack;
}
