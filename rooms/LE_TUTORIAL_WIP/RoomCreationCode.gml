physics_world_update_speed(180);

instance_create_layer(0, 0, "Instances", o_TutorialCheckpoint);

// Room-pixel trigger centres and sizes; cover each approach and the airborne crossing.
// The shared air-dash prompt shows Space + Shift and follows remapped controls.
instance_create_layer(2240, 704, "Instances", o_InputPrompt,
{
    prompt_id: "air_dash",
    trigger_width: 960, // Pixels; include the takeoff before the exposed wires.
    trigger_height: 320 // Pixels; keep the reminder visible through the jump.
});
instance_create_layer(4704, 704, "Instances", o_InputPrompt,
{
    prompt_id: "air_dash",
    trigger_width: 1152, // Pixels; include the safe approach and the grinder row.
    trigger_height: 320 // Pixels; exclude the rooms below the grinders.
});

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
