function weapon_hitscan(_damage, _range, _piercing)
{
    // =====================================
    // MUZZLE AND AIM
    // =====================================

    var _muzzle = player_get_muzzle();

    var start_x = _muzzle.muzzle_x;
    var start_y = _muzzle.muzzle_y;

    // Aim from the shot's actual start to the crosshair in room coordinates.
    // The body-based weapon angle otherwise makes shots miss the cursor up close.
    var shoot_direction = point_direction(start_x, start_y, mouse_x, mouse_y); // Degrees; follows the crosshair at any distance.
    if (start_x == mouse_x && start_y == mouse_y)
    {
        shoot_direction = aim_angle; // Keep the weapon direction when the cursor is exactly on the muzzle.
    }

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
    var _coin_style = undefined;

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
                o_Chute_Breakable,
				o_Door_UNB
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

            // Spawn before damage so lethal hits also leave a burst.
            if (instance_exists(inst) && inst.object_index != o_Coin)
            {
                var _enemy_impact = inst.object_index == oEnemyParent
                    || object_is_ancestor(inst.object_index, oEnemyParent);
                instance_create_depth(
                    check_x - lengthdir_x(1, shoot_direction),
                    check_y - lengthdir_y(1, shoot_direction),
                    -10000, o_ShotImpact,
                    { impact_direction: shoot_direction, impact_enemy: _enemy_impact }
                );
            }

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
                var _coin_x = inst.x;
                var _coin_y = inst.y;
                _coin_style = coin_ricochet(
                    inst,
                    _damage,
                    _range,
                    coin_split_y_speed_threshold
                );

                final_x = _coin_x;
                final_y = _coin_y;
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
    // Give the muzzle-to-first-coin segment the same effect as the whole chain.
    if (!is_undefined(_coin_style))
    {
        shot.line_color = _coin_style.color;
        shot.line_width = _coin_style.width;
        shot.set_coin_effects(_coin_style.bounces, _coin_style.bullet_flash);
    }
}
