function weapon_hitscan(_damage, _range, _piercing)
{
    // =====================================
    // MUZZLE AND AIM
    // =====================================

    var _muzzle = player_get_muzzle();

    var start_x = _muzzle.muzzle_x;
    var start_y = _muzzle.muzzle_y;

    var shoot_direction = aim_angle;

    // Default: bullet reaches full range.
    var final_x =
        start_x + lengthdir_x(_range, shoot_direction);

    var final_y =
        start_y + lengthdir_y(_range, shoot_direction);

    // =====================================
    // PIERCING
    // =====================================

    // 0 = first object stops bullet.
    // 1 = pass first, second stops bullet.
    // 2 = pass first two, third stops bullet.
    var max_hits = _piercing + 1;
    var hit_count = 0;
    var stopped = false;

    // Count each object only once.
    var already_hit = ds_list_create();
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
            [
                oEnemyParent,
                o_Block,
                o_Coin,
                o_SecurityCamera,
                o_Door_Breakable,
                o_Chute_Breakable
            ],
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

            // Broken cameras no longer stop shots.
            if (instance_exists(inst)
            && inst.object_index == o_SecurityCamera
            && inst.broken)
            {
                continue;
            }

            if (ds_list_find_index(already_hit, inst) != -1)
            {
                continue;
            }

            ds_list_add(already_hit, inst);

            // =================================
            // BREAKABLE BLOCK
            // =================================

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

            // =================================
            // BREAKABLE DOORS AND CHUTES
            // =================================

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
                show_debug_message("Wall hit!");
            }

            hit_count++;

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
    // HITSCAN VISUAL
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