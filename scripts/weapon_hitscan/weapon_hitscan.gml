function weapon_hitscan(_damage, _range, _piercing)
{
    // =====================================
    // AIM
    // =====================================

    var start_x = x;
    var start_y = y -5;

    var shoot_direction = point_direction(
        start_x,
        start_y,
        mouse_x,
        mouse_y
    );


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

            [oEnemyParent, o_Block, o_Coin],

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


            // Already passed through this object
            if (ds_list_find_index(already_hit, inst) != -1)
            {
                continue;
            }


            // First time encountering this object
            ds_list_add(already_hit, inst);

// =================================
// COIN
// =================================

if (instance_exists(inst)
&& inst.object_index == o_Coin)
{
    coin_ricochet(
        inst,
        _damage * 2,
        _range
    );

    // Original shot ends at the coin
    final_x = check_x;
    final_y = check_y;

    stopped = true;

    break;
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
    inst.ehp -= _damage;

    // Trigger hit sprite
    inst.hit_timer = 0.15;

    show_debug_message(
        "Enemy hit! HP: "
        + string(inst.ehp)
    );

    if (inst.ehp <= 0)
    {
        instance_destroy(inst);

        show_debug_message("Enemy killed!");
    }
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