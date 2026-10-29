view_enabled = true;
view_visible[0] = true;

// Each room has its own camera,
// so reacquire Camera 0 when entering a room.
camera = view_camera[0];
// A new room has a fresh view position; do not subtract the previous room's shake.
shake_remaining_seconds = 0;
shake_strength_pixels = 0;
shake_offset_x = 0;
shake_offset_y = 0;
