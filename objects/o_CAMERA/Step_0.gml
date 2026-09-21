// =====================================
// GET CAMERA AND VIEW SIZE
// =====================================

var cam = view_camera[0];

var view_width = camera_get_view_width(cam);
var view_height = camera_get_view_height(cam);

// =====================================
// TARGET POSITION
// =====================================

var target_x = o_Player.x - view_width / 2;
var target_y = o_Player.y - view_height / 1.4;

// =====================================
// CURRENT CAMERA POSITION
// =====================================

var cam_x = camera_get_view_x(cam);
var cam_y = camera_get_view_y(cam);

// =====================================
// DELTA TIME
// =====================================

var dt = delta_time / 1000000;

// =====================================
// FOLLOW SPEED
// =====================================

var horizontal_follow_speed = 8;
var vertical_follow_speed = 18;

// Make the camera react faster during a slam
if (o_Player.is_slamming)
{
    vertical_follow_speed = 40;
}

// Convert follow speeds into frame-independent smoothing
var horizontal_strength = 1 - exp(-horizontal_follow_speed * dt);
var vertical_strength = 1 - exp(-vertical_follow_speed * dt);

// =====================================
// MOVE CAMERA
// =====================================

cam_x += (target_x - cam_x) * horizontal_strength;
cam_y += (target_y - cam_y) * vertical_strength;

// =====================================
// APPLY CAMERA POSITION
// =====================================

camera_set_view_pos(cam, cam_x, cam_y);