var _body_facing = sign(image_xscale);

var _rig = player_rig_pose(sprite_index, image_index);

var _origin_x = sprite_get_xoffset(sprite_index);
var _origin_y = sprite_get_yoffset(sprite_index);

var _part_facing = aim_facing;

if (sprite_index == s_Player_Slide_Right)
{
    _part_facing = 1;
}
else if (sprite_index == s_Player_Slide_Left)
{
    _part_facing = -1;
}

if (_body_facing == 0)
{
    _body_facing = 1;
}

// Neck
var _neck_x =
    x + (_rig.neck_x - _origin_x) * _body_facing;

var _neck_y =
    y + _rig.neck_y - _origin_y;

// These are visual back/front sockets,
// based on the original right-facing torso.
var _back_socket_x =
    x + (_rig.back_x - _origin_x) * _body_facing;

var _back_socket_y =
    y + _rig.back_y - _origin_y;

var _front_socket_x =
    x + (_rig.front_x - _origin_x) * _body_facing;

var _front_socket_y =
    y + _rig.front_y - _origin_y;

// Assign anatomical arms to the correct visual socket.
var _shoulder_l_x = 0;
var _shoulder_l_y = 0;
var _shoulder_r_x = 0;
var _shoulder_r_y = 0;

if (_part_facing == 1)
{
    // Facing right: left arm behind, right arm in front
    _shoulder_l_x = _back_socket_x;
    _shoulder_l_y = _back_socket_y;

    _shoulder_r_x = _front_socket_x;
    _shoulder_r_y = _front_socket_y;
}
else
{
    // Facing left: right arm behind, left arm in front
    _shoulder_r_x = _back_socket_x;
    _shoulder_r_y = _back_socket_y;

    _shoulder_l_x = _front_socket_x;
    _shoulder_l_y = _front_socket_y;
}
// Pistol position: its origin is the trigger grip
var _aim_origin_x =
    (_back_socket_x + _front_socket_x) * 0.5;

var _aim_origin_y =
    (_back_socket_y + _front_socket_y) * 0.5;

var _weapon_x =
    _aim_origin_x
    + lengthdir_x(rig_weapon_distance, aim_angle);

var _weapon_y =
    _aim_origin_y
    + lengthdir_y(rig_weapon_distance, aim_angle);

// Support-hand point relative to pistol origin
var _support_dx =
    rig_support_grip_x
    - sprite_get_xoffset(s_Pistol);

var _support_dy =
    rig_support_grip_y
    - sprite_get_yoffset(s_Pistol);

// Mirror perpendicular pistol coordinates when aiming left
_support_dy *= _part_facing;

var _support_x =
    _weapon_x
    + _support_dx * dcos(aim_angle)
    + _support_dy * dsin(aim_angle);

var _support_y =
    _weapon_y
    - _support_dx * dsin(aim_angle)
    + _support_dy * dcos(aim_angle);

// Right hand operates the trigger.
// Left hand uses the support grip.
var _right_target_x = _weapon_x;
var _right_target_y = _weapon_y;

var _left_target_x = _support_x;
var _left_target_y = _support_y;

// Draw rear arm
if (_part_facing == 1)
{
    draw_ik_arm(
        s_Player_Arm_Upper_L,
        s_Player_Arm_Lower_L,
        _shoulder_l_x,
        _shoulder_l_y,
        _left_target_x,
        _left_target_y,
        rig_upper_arm_length,
        rig_lower_arm_length,
        _part_facing,
        _part_facing
    );
}
else
{
    draw_ik_arm(
        s_Player_Arm_Upper_R,
        s_Player_Arm_Lower_R,
        _shoulder_r_x,
        _shoulder_r_y,
        _right_target_x,
        _right_target_y,
        rig_upper_arm_length,
        rig_lower_arm_length,
        _part_facing,
        _part_facing
    );
}

// Torso and legs
draw_self();

// Head

// head aim rotation
var _head_base_angle = (_part_facing == 1) ? 0 : 180;

// convert the aim direction into an angle relative to the body's facing
var _head_turn =
    ((aim_angle - _head_base_angle + 540) mod 360) - 180;

// keep the movement subtle so his neck remains attached
_head_turn = clamp(_head_turn, -25, 25);

draw_sprite_ext(
    s_Player_Head,
    0,
    _neck_x,
    _neck_y,
    _part_facing,
    1,
    _head_turn,
    c_white,
    1
);

// Glock 50 Quintillion
draw_sprite_ext(
    s_Pistol,
    0,
    _weapon_x,
    _weapon_y,
    1,
    _part_facing,
    aim_angle,
    c_white,
    1
);

// Draw front arm
if (_part_facing == 1)
{
    draw_ik_arm(
        s_Player_Arm_Upper_R,
        s_Player_Arm_Lower_R,
        _shoulder_r_x,
        _shoulder_r_y,
        _right_target_x,
        _right_target_y,
        rig_upper_arm_length,
        rig_lower_arm_length,
        _part_facing,
        _part_facing
    );
}
else
{
    draw_ik_arm(
        s_Player_Arm_Upper_L,
        s_Player_Arm_Lower_L,
        _shoulder_l_x,
        _shoulder_l_y,
        _left_target_x,
        _left_target_y,
        rig_upper_arm_length,
        rig_lower_arm_length,
        _part_facing,
        _part_facing
    );
}