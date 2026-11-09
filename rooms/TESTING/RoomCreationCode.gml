physics_world_update_speed(180);

// Use the shared Scout/Drone glow while keeping the test room fully lit.
if (!instance_exists(o_Lighting))
{
    var _lighting = instance_create_depth(0, 0, -250, o_Lighting);
    _lighting.ambient_color = c_white;
    _lighting.bloom_strength = 0;
    _lighting.player_bloom_strength = 0;
    _lighting.lava_bloom_strength = 0;
    _lighting.pixelation_enabled = false;
}
