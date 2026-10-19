function seamless_capture(_player, _gate, _destination)
{
    var _fields = [
        "aim_angle", "aim_facing", "aim_rig_mode", "air_dash_cooldown", "air_dash_cooldown_timer",
        "air_dash_iframe_duration", "air_dash_speed", "alt_fire", "chip_dot_ticks", "chip_effect_durations",
        "chip_effect_timers", "chip_landing_stun_timer", "chip_sword_cooldown_timer", "chip_waiting_for_landing", "chip_wall_holding_now",
        "chip_wall_release_timer", "coin_anchor_cooldown", "coin_anchor_cooldown_timer", "coin_count", "coin_max",
        "coin_recharge_time", "coin_recharge_timer", "coin_split_y_speed_threshold", "coin_throw_forward", "coin_throw_serial",
        "coin_throw_up", "coyote_duration", "coyote_timer", "damage_blocks_damage", "damage_knockback_duration",
        "damage_knockback_lift", "damage_knockback_pending", "damage_knockback_speed", "damage_knockback_speed_x", "damage_knockback_timer",
        "dash_active", "dash_blocks_damage", "dash_burst_duration", "dash_burst_timer", "dash_chain",
        "dash_chain_jump_bonus", "dash_chain_max", "dash_chain_speed_per_dash", "dash_chain_timer", "dash_chain_window",
        "dash_cooldown", "dash_current_speed", "dash_decay", "dash_direction", "dash_iframe_is_ground",
        "dash_iframe_timer", "dash_speed", "dash_started_moving", "dash_stationary_speed", "dmg_cooldown",
        "electric_wires_lab_entered", "electric_wires_second_unlocked",
        "enemy_knock", "ground_check_x_offset", "ground_check_y_offset", "ground_dash_cooldown_timer", "ground_dash_iframe_duration",
        "image_alpha", "image_angle", "image_blend", "image_index", "image_speed",
        "image_xscale", "image_yscale", "is_ledge_climbing", "is_mantle_lunging", "is_slamming",
        "is_sliding", "item_coin_anchor", "jump_speed", "knockback_apply", "ledge_climb_duration",
        "ledge_climb_forward", "ledge_climb_timer", "ledge_direction", "ledge_start_x", "ledge_start_y",
        "ledge_target_x", "ledge_target_y", "left_wall_jumps_used", "mantle_lunge_direction", "mantle_lunge_speed",
        "mantle_lunge_up", "mask_index", "max_wall_jumps_per_side", "medkit_owned", "move_speed",
        "movement_boost_multiplier", "pHP", "pHP_max", "perfect_apex_flash_duration", "perfect_apex_flash_timer",
        "phy_fixed_rotation", "pinned_coin_offset_x", "pinned_coin_offset_y", "pistol_cooldown", "pistol_damage",
        "pistol_piercing", "pistol_range", "player_can_stand", "player_collider_short", "player_set_collider",
        "primary_fire", "rig_free_arm_frame_hold", "rig_free_arm_phase", "rig_free_arm_reach", "rig_free_arm_slide_angle",
        "rig_free_arm_swing", "rig_free_arm_swing_speed", "rig_free_hand_offset_x", "rig_free_hand_offset_y", "rig_lower_arm_length",
        "rig_muzzle_x", "rig_muzzle_y", "rig_neck_x", "rig_neck_y", "rig_shoulder_l_x",
        "rig_shoulder_l_y", "rig_shoulder_r_x", "rig_shoulder_r_y", "rig_support_grip_x", "rig_support_grip_y",
        "rig_upper_arm_length", "rig_weapon_distance", "right_wall_jumps_used", "slam_acceleration", "slam_base_damage",
        "slam_base_knockback_speed", "slam_base_radius", "slam_cooldown", "slam_cooldown_timer", "slam_damage_power_exponent",
        "slam_distance", "slam_iframe_timer", "slam_impact_iframe_duration", "slam_knockback_power_exponent", "slam_last_y",
        "slam_max_damage", "slam_max_knockback_speed", "slam_max_radius", "slam_max_speed", "slam_power",
        "slam_power_double_distance", "slam_power_max", "slam_radius_power_exponent", "slam_speed", "slide_boost_timer",
        "slide_direction", "slide_double_boost_stage", "slide_double_boost_stage1_duration", "slide_double_boost_stage1_multiplier", "slide_double_boost_stage2_duration",
        "slide_double_boost_stage2_multiplier", "slide_double_boost_stage3_duration", "slide_double_boost_timer", "slide_double_jump_direction", "slide_double_jump_launch_multiplier",
        "slide_double_jump_timer", "slide_double_jump_window", "slide_exit_delay", "slide_exit_timer", "slide_jump_speed",
        "slide_movespeed_multiplier", "slide_speed_multiplier", "slide_time", "sprite_index", "sword_config",
        "sword_slash_sound_index", "sword_swing_facing", "sword_swing_pending_hit", "sword_swing_timer", "syringe_count", "syringe_max",
        "take_damage", "timerf3", "trap_bounce_pending", "trap_bounce_speed", "trap_knockback_speed_x",
        "trap_knockback_timer", "use_syringe", "visible", "wall_jump_forced_direction", "wall_jump_lock_duration",
        "wall_jump_lock_time", "wall_jump_x", "wall_jump_y", "wall_slide_active", "wall_slide_decel",
        "wall_slide_speed", "weapon_fire_timer", "weapon_type"
    ];
    var _values = {};
    for (var _i = 0; _i < array_length(_fields); _i++)
    {
        var _name = _fields[_i];
        if (!variable_instance_exists(_player, _name)) continue;
        var _value = variable_instance_get(_player, _name);
        // Use the new player's methods; old methods are bound to the old instance.
        if (is_method(_value)) continue;
        variable_struct_set(_values, _name, _value);
    }
    var _parallax_snapshot = undefined;
    var _parallax = instance_find(o_Parallax, 0);

    if (instance_exists(_parallax))
    {
        if (_parallax.parallax_ready)
        {
            _parallax_snapshot = {
                anchor_offset_x:
                    _parallax.parallax_camera_start_x - _gate.x,

                anchor_offset_y:
                    _parallax.parallax_camera_start_y - _gate.y
            };
        }
    }

    var _cam = view_camera[0];
    return {
        destination_room: _destination,
        connection_id: _gate.connection_id,
        source_x: _gate.x,
        source_y: _gate.y,
        player_offset_x: _player.x - _gate.x,
        player_offset_y: _player.y - _gate.y,
        velocity_x: _player.phy_speed_x,
        velocity_y: _player.phy_speed_y,
        camera_offset_x: camera_get_view_x(_cam) - _gate.x,
        camera_offset_y: camera_get_view_y(_cam) - _gate.y,
        camera_width: camera_get_view_width(_cam),
        camera_height: camera_get_view_height(_cam),
        camera_angle: camera_get_view_angle(_cam),
        parallax: _parallax_snapshot,
        values: _values
    };
}

function seamless_restore(_player, _arrival, _transfer)
{
    var _names = variable_struct_get_names(_transfer.values);
    for (var _i = 0; _i < array_length(_names); _i++)
    {
        var _name = _names[_i];
        variable_instance_set(_player, _name,
            variable_struct_get(_transfer.values, _name));
    }

    var _shift_x = _arrival.x - _transfer.source_x;
    var _shift_y = _arrival.y - _transfer.source_y;
    // These movement states store WORLD positions rather than speeds.
    var _x_fields = ["ledge_start_x", "ledge_target_x"];
    var _y_fields = ["ledge_start_y", "ledge_target_y", "slam_last_y"];
    for (var _i = 0; _i < array_length(_x_fields); _i++)
    {
        var _name = _x_fields[_i];
        if (variable_instance_exists(_player, _name))
            variable_instance_set(_player, _name,
                variable_instance_get(_player, _name) + _shift_x);
    }
    for (var _i = 0; _i < array_length(_y_fields); _i++)
    {
        var _name = _y_fields[_i];
        if (variable_instance_exists(_player, _name))
            variable_instance_set(_player, _name,
                variable_instance_get(_player, _name) + _shift_y);
    }

    // Rebuild with this room's fixture handle, never the old room's handle.
    _player.player_set_collider(_player.player_collider_short);
    _player.phy_position_x = _arrival.x + _transfer.player_offset_x;
    _player.phy_position_y = _arrival.y + _transfer.player_offset_y;
    _player.phy_speed_x = _transfer.velocity_x;
    _player.phy_speed_y = _transfer.velocity_y;
    _player.phy_fixed_rotation = true;
    _player.hacking_controller = noone;
    _player.pinned_coin = noone;

    // Replace this room's old player attachments with the incoming ones.
    with (o_ChipAttachment)
    {
        if (!is_healing && target == _player)
        {
            instance_destroy();
        }
    }

    // Recreate attached CHIP VISUALS; their timers/tick counts were transferred.
    for (var _i = 0; _i < array_length(_player.chip_effect_timers); _i++)
    {
        var _remaining = _player.chip_effect_timers[_i];
        if (_remaining <= 0) continue;
        var _chip = instance_create_depth(_arrival.x, _arrival.y,
            _player.depth - 2, o_ChipAttachment);
        _chip.target = _player;
        _chip.effect = _i;
        _chip.duration = _remaining;
    }

    var _cam = view_camera[0];
    camera_set_view_size(_cam, _transfer.camera_width, _transfer.camera_height);
    camera_set_view_angle(_cam, _transfer.camera_angle);
    camera_set_view_pos(_cam,
        _arrival.x + _transfer.camera_offset_x,
        _arrival.y + _transfer.camera_offset_y);
		    // Continue parallax from the source room's reference point.
    if (variable_struct_exists(_transfer, "parallax"))
    {
        if (!is_undefined(_transfer.parallax))
        {
            var _parallax = instance_find(o_Parallax, 0);

            if (instance_exists(_parallax))
            {
                _parallax.parallax_camera_start_x =
                    _arrival.x
                    + _transfer.parallax.anchor_offset_x;

                _parallax.parallax_camera_start_y =
                    _arrival.y
                    + _transfer.parallax.anchor_offset_y;

                _parallax.parallax_ready = true;
            }
        }
    }
    var _camera_object = instance_find(o_CAMERA, 0);
    if (!instance_exists(_camera_object))
        _camera_object = instance_create_depth(0, 0, -100, o_CAMERA);
    _camera_object.camera = _cam;
    _camera_object.seamless_hold_frames = 1;
	function seamless_rebuild_room_physics()
{
    // Walls, floors and surviving breakable blocks.
    with (o_Block)
    {
        if (variable_instance_exists(id, "broken") && broken)
        {
            continue;
        }

        var _width =
            sprite_get_width(sprite_index) * abs(image_xscale);

        var _height =
            sprite_get_height(sprite_index) * abs(image_yscale);

        var _fix = physics_fixture_create();

        physics_fixture_set_box_shape(
            _fix, _width / 2, _height / 2
        );

        physics_fixture_set_density(_fix, 0);
        physics_fixture_set_friction(_fix, 0.5);
        physics_fixture_set_restitution(_fix, 0);
        physics_fixture_set_collision_group(_fix, 1);

        // Match the offsets used by each object's Create event.
        var _offset_x = _width / 2;
        var _offset_y = _height / 2;

        if (object_index == o_Block_Breakable)
        {
            _offset_x = (
                sprite_get_width(sprite_index) / 2
                - sprite_get_xoffset(sprite_index)
            ) * image_xscale;

            _offset_y = (
                sprite_get_height(sprite_index) / 2
                - sprite_get_yoffset(sprite_index)
            ) * image_yscale;
        }

        physics_fixture_bind_ext(
            _fix, id, _offset_x, _offset_y
        );

        physics_fixture_delete(_fix);
    }

    // Thick doors: open doors remain nonblocking.
    with (o_Door_UNB)
    {
        door_fixture = -1;

        if (door_state == 2)
        {
            continue;
        }

        var _fix = physics_fixture_create();

        physics_fixture_set_box_shape(_fix, 16, 32);
        physics_fixture_set_density(_fix, 0);
        physics_fixture_set_friction(_fix, 0.5);
        physics_fixture_set_restitution(_fix, 0);
        physics_fixture_set_collision_group(_fix, 1);

        door_fixture = physics_fixture_bind_ext(
            _fix,
            id,
            sprite_get_width(sprite_index) / 2
                - sprite_get_xoffset(sprite_index),
            sprite_get_height(sprite_index) / 2
                - sprite_get_yoffset(sprite_index)
        );

        physics_fixture_delete(_fix);
    }

    // Surviving breakable doors and chutes.
    var _door_objects = [
        o_Door_Breakable,
        o_Chute_Breakable
    ];

    for (var _i = 0; _i < array_length(_door_objects); _i++)
    {
        with (_door_objects[_i])
        {
            door_fixture = -1;

            if (broken)
            {
                continue;
            }

            var _width =
                sprite_get_width(sprite_index) * abs(image_xscale);

            var _height =
                sprite_get_height(sprite_index) * abs(image_yscale);

            var _fix = physics_fixture_create();

            physics_fixture_set_box_shape(
                _fix, _width / 2, _height / 2
            );

            physics_fixture_set_density(_fix, 0);
            physics_fixture_set_friction(_fix, 0.5);
            physics_fixture_set_restitution(_fix, 0);
            physics_fixture_set_collision_group(_fix, 1);

            door_fixture = physics_fixture_bind_ext(
                _fix,
                id,
                (
                    sprite_get_width(sprite_index) / 2
                    - sprite_get_xoffset(sprite_index)
                ) * image_xscale,
                (
                    sprite_get_height(sprite_index) / 2
                    - sprite_get_yoffset(sprite_index)
                ) * image_yscale
            );

            physics_fixture_delete(_fix);
        }
    }
}
}
