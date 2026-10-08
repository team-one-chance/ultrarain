function player_get_muzzle()
{
    var _body_facing = sign(image_xscale);
    if (_body_facing == 0) _body_facing = 1;

    var _part_facing = aim_facing;

    if (sprite_index == s_Player_Slide_Right)
    {
        _part_facing = 1;
    }
    else if (sprite_index == s_Player_Slide_Left)
    {
        _part_facing = -1;
    }

    var _rig = player_rig_pose(sprite_index, image_index);

    var _origin_x = sprite_get_xoffset(sprite_index);
    var _origin_y = sprite_get_yoffset(sprite_index);

    var _back_x =
        x + (_rig.back_x - _origin_x) * _body_facing;

    var _back_y =
        y + _rig.back_y - _origin_y;

    var _front_x =
        x + (_rig.front_x - _origin_x) * _body_facing;

    var _front_y =
        y + _rig.front_y - _origin_y;

    var _aim_x;
    var _aim_y;

    if (aim_rig_mode == AimRigMode.ONE_HANDED)
    {
        if (_body_facing == 1)
        {
            _aim_x = _front_x;
            _aim_y = _front_y;
        }
        else
        {
            _aim_x = _back_x;
            _aim_y = _back_y;
        }
    }
    else
    {
        _aim_x = (_back_x + _front_x) * 0.5;
        _aim_y = (_back_y + _front_y) * 0.5;
    }

    var _weapon_x =
        _aim_x + lengthdir_x(rig_weapon_distance, aim_angle);

    var _weapon_y =
        _aim_y + lengthdir_y(rig_weapon_distance, aim_angle);

    var _dx = rig_muzzle_x - sprite_get_xoffset(s_Pistol);

    var _dy =
        (rig_muzzle_y - sprite_get_yoffset(s_Pistol))
        * _part_facing;

    return {
        muzzle_x:
            _weapon_x
            + _dx * dcos(aim_angle)
            + _dy * dsin(aim_angle),

        muzzle_y:
            _weapon_y
            - _dx * dsin(aim_angle)
            + _dy * dcos(aim_angle)
    };
}