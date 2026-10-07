function weapon_hitscan(_damage, _range, _piercing)
{
    // =====================================
    // AIM
    // =====================================

// =====================================
// GET ACTUAL PISTOL MUZZLE POSITION
// =====================================

// Body direction
var _body_facing = sign(image_xscale);

if (_body_facing == 0)
{
    _body_facing = 1;
}


// Direction the gun/arms are aiming
var _part_facing = aim_facing;

// Slides use direction-specific sprites
if (sprite_index == s_Player_Slide_Right)
{
    _part_facing = 1;
}
else if (sprite_index == s_Player_Slide_Left)
{
    _part_facing = -1;
}


// Get the current rig pose
var _rig =
    player_rig_pose(
        sprite_index,
        image_index
    );

var _origin_x =
    sprite_get_xoffset(sprite_index);

var _origin_y =
    sprite_get_yoffset(sprite_index);


// =====================================
// SHOULDER SOCKETS
// =====================================

var _back_socket_x =
    x
    + (_rig.back_x - _origin_x)
    * _body_facing;

var _back_socket_y =
    y
    + _rig.back_y
    - _origin_y;

var _front_socket_x =
    x
    + (_rig.front_x - _origin_x)
    * _body_facing;

var _front_socket_y =
    y
    + _rig.front_y
    - _origin_y;


// Match the anatomical firing shoulder used by Draw.
var _shoulder_r_x;
var _shoulder_r_y;

if (_body_facing == 1)
{
    _shoulder_r_x = _front_socket_x;
    _shoulder_r_y = _front_socket_y;
}
else
{
    _shoulder_r_x = _back_socket_x;
    _shoulder_r_y = _back_socket_y;
}


// =====================================
// PISTOL POSITION
// =====================================

var _aim_origin_x;
var _aim_origin_y;

if (aim_rig_mode == AimRigMode.ONE_HANDED)
{
    _aim_origin_x = _shoulder_r_x;
    _aim_origin_y = _shoulder_r_y;
}
else
{
    _aim_origin_x =
        (_back_socket_x + _front_socket_x)
        * 0.5;

    _aim_origin_y =
        (_back_socket_y + _front_socket_y)
        * 0.5;
}


var _weapon_x =
    _aim_origin_x
    + lengthdir_x(
        rig_weapon_distance,
        aim_angle
    );

var _weapon_y =
    _aim_origin_y
    + lengthdir_y(
        rig_weapon_distance,
        aim_angle
    );


// =====================================
// MUZZLE POSITION
// =====================================

// Position of muzzle relative to pistol origin
var _muzzle_dx =
    rig_muzzle_x
    - sprite_get_xoffset(s_Pistol);

var _muzzle_dy =
    rig_muzzle_y
    - sprite_get_yoffset(s_Pistol);

// Same vertical mirror used when drawing pistol
_muzzle_dy *= _part_facing;


// Rotate local muzzle position into world space
var start_x =
    _weapon_x
    + _muzzle_dx * dcos(aim_angle)
    + _muzzle_dy * dsin(aim_angle);

var start_y =
    _weapon_y
    - _muzzle_dx * dsin(aim_angle)
    + _muzzle_dy * dcos(aim_angle);


// Shoot exactly along the direction the pistol is drawn
var shoot_direction = aim_angle;


    // Default: bullet reaches full range
    var final_x =
        start_x + lengthdir_x(_range, shoot_direction);

    var final_y =
        start_y + lengthdir_y(_range, shoot_direction);


    // =====================================
    // PIERCING
    // =====================================

    // piercing 0 = first object stops bullet
    // piercing 1 = pass first, second stops bullet
    // piercing 2 = pass first two, third stops bullet

    var max_hits = _piercing + 1;
    var hit_count = 0;

    var stopped = false;


    // Keep track of objects we've already hit.
    // Otherwise a 16px-wide wall would count 16 times.
    var already_hit = ds_list_create();

    // Temporary list for objects at each point
    var point_hits = ds_list_create();


    // =====================================
    // WALK ALONG THE RAY
    // =====================================

    for (var dist = 0; dist <= _range; dist += 1)
    {
        var check_x =
            start_x + lengthdir_x(dist, shoot_direction);

        var check_y =
            start_y + lengthdir_y(dist, shoot_direction);


        ds_list_clear(point_hits);


        collision_point_list(
            check_x,
            check_y,

            [oEnemyParent, o_Block, o_Coin, o_SecurityCamera, o_Door_Breakable, o_Chute_Breakable],

            false,
            true,
            point_hits,
            false
        );


        // =================================
        // PROCESS NEW OBJECTS
        // =================================

        for (var i = 0; i < ds_list_size(point_hits); i++)
        {
            var inst = point_hits[| i];
			
			// Broken doors no longer stop shots.
if (instance_exists(inst)
&& variable_instance_exists(inst, "door_take_damage"))
{
    if (inst.broken || inst.break_requested)
    {
        continue;
    }
}
			
			// Broken cameras no longer stop bullets.
			if (instance_exists(inst)
			&& inst.object_index == o_SecurityCamera
			&& inst.broken)
			{
			    continue;
			}


            // Already passed through this object
            if (ds_list_find_index(already_hit, inst) != -1)
            {
                continue;
            }


            // First time encountering this object
            ds_list_add(already_hit, inst);
			// Breakable blocks are already detected through parent o_Block.
if (instance_exists(inst)
&& inst.object_index == o_Block_Breakable)
{
    inst.take_damage(_damage);
}

// =================================
// COIN
// =================================

if (instance_exists(inst)
&& inst.object_index == o_Coin)
{
	coin_ricochet(
		inst,
		_damage,
		_range,
		coin_split_y_speed_threshold
				);

    // Original shot ends at the coin
    final_x = check_x;
    final_y = check_y;

    stopped = true;

    break;
}

// =================================
// SECURITY CAMERA
// =================================

if (instance_exists(inst)
&& inst.object_index == o_SecurityCamera)
{
    inst.camera_break();
}
// Damage breakable doors and chutes once per shot.
if (instance_exists(inst)
&& variable_instance_exists(inst, "door_take_damage"))
{
    inst.door_take_damage(_damage);
}

            // =================================
            // ENEMY
            // =================================
			
			

          if (instance_exists(inst)
&& (
    inst.object_index == oEnemyParent
    || object_is_ancestor(inst.object_index, oEnemyParent)
))
{
    inst.take_damage(_damage);
}


            // =================================
            // WALL
            // =================================

            else if (instance_exists(inst)
            && inst.object_index == o_Block)
            {
                show_debug_message(
                    "Wall hit!"
                );
            }


            // This object consumed one hit
            hit_count++;


            // =================================
            // OUT OF PIERCING
            // =================================

            if (hit_count >= max_hits)
            {
                final_x = check_x;
                final_y = check_y;

                stopped = true;
                break;
            }
        }


        if (stopped)
        {
            break;
        }
    }


    // =====================================
    // CLEANUP
    // =====================================

    ds_list_destroy(point_hits);
    ds_list_destroy(already_hit);


    // =====================================
    // YELLOW HITSCAN VISUAL
    // =====================================

    var shot = instance_create_layer(
        0,
        0,
        "Instances",
        o_HitscanVisual
    );

    shot.line_x1 = start_x;
    shot.line_y1 = start_y;

    shot.line_x2 = final_x;
    shot.line_y2 = final_y;
}