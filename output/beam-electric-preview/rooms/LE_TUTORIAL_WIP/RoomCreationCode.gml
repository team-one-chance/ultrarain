physics_world_update_speed(180);

instance_create_layer(0, 0, "Instances", o_TutorialCheckpoint);

// Keep the tall wire wall quiet until its top platform is reached.
// Lab03's upper doorway is under the sign at (4128, 736), beside the wire wall.
with (o_Player)
{
    electric_wires_delayed_object = o_Block_wires_right;
    electric_wires_activation_platform = inst_6FE1CBC0;
    electric_wires_lab_door = { x: 4160, top: 768, bottom: 832, direction: 1 };
    electric_wires_second_unlocked = false;
}

// The painted background layers need a controller to follow the camera.
if (!instance_exists(o_Parallax))
{
    instance_create_layer(0, 0, "Instances", o_Parallax);
}
