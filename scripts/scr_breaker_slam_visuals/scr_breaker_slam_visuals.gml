/// Shared Breaker slam VFX (visual effects) settings for TESTING and every level.
/// Edit this block, then stop and restart the game to load the source changes.
function breaker_slam_visual_settings()
{
    // Initialize once per game, not once per room. Runtime edits survive room changes.
    if (!variable_global_exists("breaker_slam_visuals"))
    {
        global.breaker_slam_visuals = {
            radius_pixels: 64, // Maximum spread on EACH side; 32 pixels = one block.
            duration_seconds: 0.28, // Lifetime of the entire animation; all timing scales with this.
            wind_colour: make_color_rgb(255, 220, 255), // Main gust and ground-streak color; (255, 255, 255) is pure white.
            shade_colour: make_color_rgb(205, 215, 220), // Inner edge and dust color.
            flash_colour: c_white, // Color of the brief contact flash.
            opacity: 1, // Overall visibility, from 0 (invisible) to 1 (full).
            wind_height_pixels: 18, // Height of the outer curl; larger values make taller gusts.
            wind_width_pixels: 3.5, // Thickness of the outer wind ribbon.
            wind_layers: 3, // Number of staggered ribbons on each side.
            layer_delay_fraction: 0.08, // Delay between layers as a fraction of the total lifetime.
            dust_count: 14, // Total number of pale dust puffs, split between both sides.
            dust_size_pixels: 5, // Maximum initial dust-puff radius.
            dust_opacity: 0.16, // Dust visibility, multiplied by overall opacity.
            flash_duration_fraction: 0.16, // Fraction of the lifetime occupied by the contact flash.
            flash_radius_pixels: 22, // Horizontal half-width of the contact flash.
            flash_height_pixels: 8 // Height of the pointed compression flash.
        };
    }
    return global.breaker_slam_visuals;
}
