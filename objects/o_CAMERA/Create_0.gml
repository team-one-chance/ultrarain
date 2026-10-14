// Keep the existing persistent camera controller.
if (instance_number(o_CAMERA) > 1)
{
    instance_destroy();
    exit;
}

persistent = true;

view_enabled = true;
view_visible[0] = true;

camera = view_camera[0];
seamless_hold_frames = 0;