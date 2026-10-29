/// Shared Breaker landing camera settings for TESTING and every gameplay room.
/// The slam particle and pressure-burst visual effect has been removed.
function breaker_slam_visual_settings()
{
    // Initialize once per game; runtime tuning survives room changes.
    if (!variable_global_exists("breaker_slam_visuals"))
    {
        global.breaker_slam_visuals = {
            camera_shake_pixels: 2, // Maximum camera displacement per axis in room pixels; zero disables shake.
            camera_shake_seconds: 0.16 // Shake lifetime in seconds; larger values make the impact rumble longer.
        };
    }
    return global.breaker_slam_visuals;
}
