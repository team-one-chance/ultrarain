var _grinder_old_matrix = matrix_get(matrix_world);

// Draw offset red silhouettes behind the assembled pose. An active shader also
// guards the repeated Draw calls and leaves the lighting extraction pass intact.
if (pHP > 0 && pHP_max > 0 && pHP <= pHP_max * low_health_outline_threshold
    && !grinder_dying && shader_current() == -1 && shader_is_compiled(sh_PlayerLowHealth))
{
    var _pulse = 0.5 + 0.5 * cos(
        (current_time / 1000) * 2 * pi / max(0.001, low_health_outline_period)
    );
    shader_set(sh_PlayerLowHealth);
    shader_set_uniform_f(low_health_outline_uniform,
        lerp(low_health_outline_alpha_min, low_health_outline_alpha_max, _pulse));

    for (var _outline_pass = 0; _outline_pass < 8; _outline_pass++)
    {
        var _outline_angle = _outline_pass * 45; // Degrees; eight directions cover the silhouette corners.
        var _outline_matrix = matrix_build(
            lengthdir_x(low_health_outline_width, _outline_angle),
            lengthdir_y(low_health_outline_width, _outline_angle), 0,
            0, 0, 0, 1, 1, 1
        );
        matrix_set(matrix_world, matrix_multiply(_outline_matrix, _grinder_old_matrix));
        event_perform(ev_draw, 0);
    }

    matrix_set(matrix_world, _grinder_old_matrix);
    shader_reset();
}

if (grinder_dying)
{
    var _crush = clamp(
        (grinder_elapsed - grinder_pull_duration)
        / grinder_crush_duration,
        0, 1
    );

    var _cx = x + grinder_pivot_x;
    var _cy = y + grinder_pivot_y;

    var _to_origin = matrix_build(
        -_cx, -_cy, 0,
        0, 0, 0,
        1, 1, 1
    );

    var _squeeze = matrix_build(
        0, 0, 0,
        0, 0, 0,
        lerp(1, 0.12, _crush),
        lerp(1, 0.55, _crush),
        1
    );

    var _back = matrix_build(
        _cx, _cy, 0,
        0, 0, 0,
        1, 1, 1
    );

    var _transform = matrix_multiply(_to_origin, _squeeze);
    _transform = matrix_multiply(_transform, _back);
    _transform = matrix_multiply(
        _transform, _grinder_old_matrix
    );

    matrix_set(matrix_world, _transform);
}

// physics_world_draw_debug(phy_debug_render_shapes);

if (!grinder_dying && parry_is_active())
{
    var _progress = 1 - parry_timer / max(0.001, parry_duration);

    var _frame = min(
        sprite_get_number(s_parry_TEMP) - 1,
        floor(_progress * sprite_get_number(s_parry_TEMP))
    );

    draw_sprite_ext(
        s_parry_TEMP,
        _frame,
        x,
        y,
        parry_animation_facing,
        1,
        0,
        c_white,
        1
    );

    // Don't draw the normal player body or weapon rig.
    exit;
}

var _body_facing = sign(image_xscale);

var _rig = player_rig_pose(sprite_index, image_index);

var _origin_x = sprite_get_xoffset(sprite_index);
var _origin_y = sprite_get_yoffset(sprite_index);

var _part_facing = aim_facing;

var _hide_rest_arm =
    aim_rig_mode == AimRigMode.ONE_HANDED
    && (
        sprite_index == s_Player_wallHold_Left
        || sprite_index == s_Player_wallHold_Right
    );

var _arm_layer_facing = _body_facing;

if (sprite_index == s_Player_wallHold_Left)
{
    // Gun arm behind torso
    _arm_layer_facing = -1;
}
else if (sprite_index == s_Player_wallHold_Right)
{
    // Gun arm in front of torso
    _arm_layer_facing = 1;
}

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

if (weapon_type == "sword")
{
    // Keep the weapon and its slash aligned throughout the swing.
    if (sword_swing_timer > 0)
    {
        _part_facing = sword_swing_facing;
    }
    else
    {
        _part_facing = aim_facing;
        if (_part_facing == 0) _part_facing = _body_facing;
    }
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

if (_body_facing == 1)
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
var _aim_origin_x;
var _aim_origin_y;

if (aim_rig_mode == AimRigMode.ONE_HANDED)
{
    // Measure pistol distance directly from the firing shoulder
    _aim_origin_x = _shoulder_r_x;
    _aim_origin_y = _shoulder_r_y;
}
else
{
    // Two-handed weapons remain centred between both shoulders
    _aim_origin_x =
        (_back_socket_x + _front_socket_x) * 0.5;

    _aim_origin_y =
        (_back_socket_y + _front_socket_y) * 0.5;
}

var _sword_angle = 0;
var _sword_forward_angle = 0;
var _sword_grip_reach = 0;

if (weapon_type == "sword")
{
    // Use cursor height on either side of the player; moving the cursor
    // across the body should not flip the sword from up to down.
    var _pitch_angle = point_direction(
        0, 0,
        max(1, abs(mouse_x - _aim_origin_x)),
        mouse_y - _aim_origin_y
    );

    if (_pitch_angle > 180)
    {
        _pitch_angle -= 360;
    }

    var _sword_pitch = clamp(
        _pitch_angle,
        -sword_config.aim_pitch_limit,
        sword_config.aim_pitch_limit
    );

    var _sword_pose_angle = sword_config.rest_angle;

    if (sword_swing_timer > 0)
    {
        var _swing_progress = 1 - sword_swing_timer / max(0.001, sword_config.swing_duration);
        var _windup_end = clamp(sword_config.windup_phase, 0.001, 0.998);
        var _strike_end = clamp(sword_config.follow_through_phase, _windup_end + 0.001, 0.999);
        var _follow_angle = sword_config.windup_angle - sword_config.swing_arc;

        if (_swing_progress < _windup_end)
        {
            _sword_pose_angle = lerp(
                sword_config.rest_angle,
                sword_config.windup_angle,
                _swing_progress / _windup_end
            );
        }
        else if (_swing_progress < _strike_end)
        {
            _sword_pose_angle = lerp(
                sword_config.windup_angle,
                _follow_angle,
                (_swing_progress - _windup_end) / (_strike_end - _windup_end)
            );
        }
        else
        {
            _sword_pose_angle = lerp(
                _follow_angle,
                sword_config.rest_angle,
                (_swing_progress - _strike_end) / (1 - _strike_end)
            );
        }
    }

    // The hilt sweeps around the shoulders while the blade rotates.
    var _hand_pitch = clamp(
        _sword_pitch
            + (_sword_pose_angle - sword_config.rest_angle) * sword_config.swing_hand_follow,
        -sword_config.swing_hand_pitch_limit,
        sword_config.swing_hand_pitch_limit
    );
    _sword_forward_angle = (_part_facing == 1)
        ? _hand_pitch
        : 180 - _hand_pitch;
    var _full_swing_offset = max(
        1,
        max(
            abs(sword_config.windup_angle - sword_config.rest_angle),
            abs(sword_config.windup_angle - sword_config.swing_arc - sword_config.rest_angle)
        )
    );
    _sword_grip_reach = max(
        0,
        sword_config.grip_forward
            - sword_config.swing_grip_retract
                * abs(_sword_pose_angle - sword_config.rest_angle) / _full_swing_offset
    );
    _sword_angle = (
        _sword_pose_angle + _sword_pitch * sword_config.aim_blade_follow
    ) * _part_facing;
}

var _weapon_x =
    _aim_origin_x
    + lengthdir_x(rig_weapon_distance, aim_angle);

var _weapon_y =
    _aim_origin_y
    + lengthdir_y(rig_weapon_distance, aim_angle);

if (weapon_type == "sword")
{
    // Move the hilt through an arc that both arms can follow.
    _weapon_x = _aim_origin_x
        + lengthdir_x(_sword_grip_reach, _sword_forward_angle);
    _weapon_y = _aim_origin_y + sword_config.grip_down
        + lengthdir_y(sword_config.aim_vertical_reach, _sword_forward_angle);
}

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

if (weapon_type == "sword")
{
    // Rotate the support grip with the blade through the whole swing.
    var _grip_dx = -sword_config.support_hand_back * _part_facing;
    var _grip_dy = sword_config.support_hand_down;
    _support_x = _weapon_x
        + _grip_dx * dcos(_sword_angle)
        + _grip_dy * dsin(_sword_angle);
    _support_y = _weapon_y
        - _grip_dx * dsin(_sword_angle)
        + _grip_dy * dcos(_sword_angle);
}

// Primary hand target
var _right_target_x = _weapon_x;
var _right_target_y = _weapon_y;

if (weapon_type == "sword")
{
    _right_target_x -= sword_config.main_hand_up * dsin(_sword_angle);
    _right_target_y -= sword_config.main_hand_up * dcos(_sword_angle);
}

var _left_target_x;
var _left_target_y;
var _rest_arm_facing = _body_facing;

if (aim_rig_mode == AimRigMode.TWO_HANDED)
{
    // Left hand holds the weapon
    _left_target_x = _support_x;
    _left_target_y = _support_y;
}
else
{
    // Default: arm hanging downward
    var _free_arm_angle = 270;

    // Slide sprites are already drawn facing left/right, both at xscale 1.
    // Raise the free hand behind the torso and mirror the elbow with the slide.
    if (sprite_index == s_Player_Slide_Right)
    {
        _rest_arm_facing = 1;
        _free_arm_angle = rig_free_arm_slide_angle;
    }
    else if (sprite_index == s_Player_Slide_Left)
    {
        _rest_arm_facing = -1;
        _free_arm_angle = 180 - rig_free_arm_slide_angle;
    }

    // Swing the free arm while running
	if (sprite_index == s_Player_Run)
	{
		var _arm_frame =
			floor(image_index / rig_free_arm_frame_hold)
			* rig_free_arm_frame_hold;

		var _run_cycle =
			(_arm_frame / max(1, image_number)) * 360;

		_free_arm_angle +=
			dsin(_run_cycle + rig_free_arm_phase)
			* rig_free_arm_swing
			* _body_facing;
	}

    _left_target_x =
        _shoulder_l_x
        + lengthdir_x(rig_free_arm_reach, _free_arm_angle);

    _left_target_y =
        _shoulder_l_y
        + lengthdir_y(rig_free_arm_reach, _free_arm_angle);
}

// Draw rear arm
if (_arm_layer_facing == 1)
{
    // Left arm is the resting arm
    if (!_hide_rest_arm)
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
            _rest_arm_facing,
            _rest_arm_facing
        );
    }
}
else
{
    // Right arm holds the equipped weapon
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

if (weapon_type == "sword")
{
    draw_sprite_ext(
        sDarkRepulsor, 0, _weapon_x, _weapon_y,
        1, 1, _sword_angle, c_white, 1
    );
}
else if (weapon_type == "pistol")
{
    // Glock 50 Quintillion (who does bro think he is)
    draw_sprite_ext(
        s_Pistol, 0, _weapon_x, _weapon_y,
        1, _part_facing, aim_angle, c_white, 1
    );
}

// Draw front arm
// Draw front arm
if (_arm_layer_facing == 1)
{
    // Right arm holds the equipped weapon
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
    // Left arm is the resting arm
    if (!_hide_rest_arm)
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
            _rest_arm_facing,
            _rest_arm_facing
        );
    }
}

// draw_text(x - 30, y - 80, sprite_get_name(sprite_index));

matrix_set(matrix_world, _grinder_old_matrix);
