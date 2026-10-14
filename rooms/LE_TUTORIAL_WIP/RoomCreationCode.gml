physics_world_update_speed(180);

// The painted background layers need a controller to follow the camera.
if (!instance_exists(o_Parallax))
{
    instance_create_layer(0, 0, "Instances", o_Parallax);
}
