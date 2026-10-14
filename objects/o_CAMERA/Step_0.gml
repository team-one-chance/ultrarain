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

camera_set_view_pos(cam, cam_x, cam_y);



