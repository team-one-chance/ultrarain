physics_world_update_speed(180);

// Hidden until the breakable entrance is broken and the player crosses into its ambush room.
if (!instance_exists(oSamuel)) instance_create_depth(0, 0, -2, oSamuel);

// Background movement for this room.
if (!instance_exists(o_Parallax))
{
    instance_create_layer(
        0, 0, "Instances", o_Parallax
    );
}

// Lighting for this room.
if (!instance_exists(o_Lighting))
{
    instance_create_depth(
        0, 0, -13000, o_Lighting
    );
}
