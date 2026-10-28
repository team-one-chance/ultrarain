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

shake_remaining_seconds = 0; // Simulation seconds left in the current camera shake.
shake_duration_seconds = 0; // Full duration in seconds, used to fade the displacement.
shake_strength_pixels = 0; // Peak displacement per axis in room pixels.
shake_offset_x = 0; // Previous horizontal displacement in pixels, removed before following.
shake_offset_y = 0; // Previous vertical displacement in pixels, removed before following.

start_shake = function(_pixels, _seconds)
{
    if (_pixels <= 0 || _seconds <= 0) return;
    shake_strength_pixels = max(shake_strength_pixels, _pixels);
    shake_duration_seconds = max(shake_remaining_seconds, _seconds);
    shake_remaining_seconds = shake_duration_seconds;
};
