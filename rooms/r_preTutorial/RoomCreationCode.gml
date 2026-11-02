// Match the tutorial physics simulation rate, in updates per second.
physics_world_update_speed(180);

// Provide the normal following camera when entering directly into this room.
if (!instance_exists(o_CAMERA))
{
    instance_create_layer(0, 0, "Player", o_CAMERA);
}

// Drive the far tile layers from the camera, as in the tutorial room.
if (!instance_exists(o_Parallax))
{
    instance_create_layer(0, 0, "Player", o_Parallax);
}

// Room-owned state never survives a simulation exit.
instance_create_layer(0, 0, "Instances", o_TrainingSimulation);
