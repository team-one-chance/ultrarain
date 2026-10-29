// Remove the previous shake before following so repeated impacts cannot cause drift.
if (camera != -1)
{
    camera_set_view_pos(camera,
        camera_get_view_x(camera) - shake_offset_x,
        camera_get_view_y(camera) - shake_offset_y);
}
shake_offset_x = 0;
shake_offset_y = 0;
var _shake_dt = max(0, (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) / 1000000); // Simulation seconds; respects pause and slow motion.
shake_remaining_seconds = max(0, shake_remaining_seconds - _shake_dt);
if (shake_remaining_seconds <= 0) shake_strength_pixels = 0;

// Freecam takes priority over train framing and seamless gate framing.
if (variable_global_exists("dev_freecam") && global.dev_freecam)
{
    var _free_cam = view_camera[0];
    if (_free_cam == -1) exit;

    var _dx = keyboard_check(ord("D")) - keyboard_check(ord("A"));
    var _dy = keyboard_check(ord("S")) - keyboard_check(ord("W"));
    var _length = point_distance(0, 0, _dx, _dy);

    if (_length > 0)
    {
        _dx /= _length;
        _dy /= _length;
    }

    var _speed = keyboard_check(vk_shift)
        ? global.dev_freecam_fast_speed
        : global.dev_freecam_speed;
    var _dt = min(delta_time / 1000000, 0.05);

    camera_set_view_pos(
        _free_cam,
        camera_get_view_x(_free_cam) + _dx * _speed * _dt,
        camera_get_view_y(_free_cam) + _dy * _speed * _dt
    );
    exit;
}
// Room Start restored the exact source-camera framing.
if (variable_instance_exists(id, "seamless_hold_frames") && seamless_hold_frames > 0)
{
    seamless_hold_frames--;
    exit;
}

if (!instance_exists(o_Player))
{
    exit;
}

// =====================================
// GET CAMERA AND VIEW SIZE
// =====================================

var cam = camera;

var view_width = camera_get_view_width(cam);
var view_height = camera_get_view_height(cam);

// =====================================
// TARGET POSITION
// =====================================

var target_x = o_Player.x - view_width / 2;
var target_y = o_Player.y - view_height / 1.4;

// Hold the camera on the stationary cabin while the scenery moves.
var _train = instance_find(o_TrainRide, 0);
if (instance_exists(_train) && _train.ride_started && !_train.arrived)
{
    target_x = _train.camera_target_x - view_width / 2;
    target_y = _train.camera_target_y - view_height / 1.4;
}


// Ease toward the crossing line in either room, then release as you leave.
// The train camera takes priority while travelling.
var _train_camera_active = instance_exists(_train) && _train.ride_started && !_train.arrived;
if (!_train_camera_active)
{
    var _focus_gate = noone;
    var _best_weight = 0;
    for (var _i = 0; _i < instance_number(o_SeamlessGate); _i++)
    {
        var _gate = instance_find(o_SeamlessGate, _i);
        if (abs(o_Player.y - _gate.y) > _gate.vertical_tolerance) continue;
        var _weight = clamp(1 - abs(o_Player.x - _gate.x)
            / max(1, _gate.camera_approach_distance), 0, 1);
        _weight = _weight * _weight * (3 - 2 * _weight);
        if (_weight > _best_weight)
        {
            _best_weight = _weight;
            _focus_gate = _gate;
        }
    }
    if (_focus_gate != noone)
    {
        target_x = lerp(target_x,
            _focus_gate.x + _focus_gate.camera_focus_offset_x - view_width / 2,
            _best_weight);
        target_y = lerp(target_y,
            _focus_gate.y + _focus_gate.camera_focus_offset_y - view_height / 1.4,
            _best_weight);
    }
}

// =====================================
// CURRENT CAMERA POSITION
// =====================================

var cam_x = camera_get_view_x(cam);
var cam_y = camera_get_view_y(cam);

// =====================================
// DELTA TIME
// =====================================

var dt = (variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000;

// =====================================
// FOLLOW SPEED
// =====================================

var horizontal_follow_speed = 8;
var vertical_follow_speed = 18;



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

if (shake_remaining_seconds > 0)
{
    var _shake_strength = shake_strength_pixels * shake_remaining_seconds / shake_duration_seconds; // Pixels; fades linearly to zero.
    shake_offset_x = random_range(-_shake_strength, _shake_strength);
    shake_offset_y = random_range(-_shake_strength, _shake_strength);
}
camera_set_view_pos(cam, cam_x + shake_offset_x, cam_y + shake_offset_y);
