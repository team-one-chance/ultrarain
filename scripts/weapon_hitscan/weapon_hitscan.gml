function weapon_hitscan(_damage, _range, _piercing)
{
    // =====================================
    // AIM / MUZZLE
    // =====================================

    var aim_x = x;
    var aim_y = y - 12;

    var shoot_direction = point_direction(
        aim_x,
        aim_y,
        mouse_x,
        mouse_y
    );

    var muzzle_distance = 12;

    var start_x =
        aim_x + lengthdir_x(muzzle_distance, shoot_direction);

    var start_y =
        aim_y + lengthdir_y(muzzle_distance, shoot_direction);


    // =====================================
    // FULL RAY
    // =====================================

    var end_x =
        start_x + lengthdir_x(_range, shoot_direction);

    var end_y =
        start_y + lengthdir_y(_range, shoot_direction);


    // This will contain BOTH walls and enemies
    var all_hits = [];


    // =====================================
    // PHYSICS WALLS
    // =====================================

    var wall_hits = physics_raycast(
        start_x,
        start_y,
        end_x,
        end_y,
        o_Block,
        true
    );

    if (!is_undefined(wall_hits))
    {
        for (var i = 0; i < array_length(wall_hits); i++)
        {
            var wall_hit = wall_hits[i];

            array_push(
                all_hits,
                {
                    instance: wall_hit.instance,
                    type: "wall",

                    // physics_raycast already gives exact distance fraction
                    fraction: wall_hit.fraction,

                    hit_x: wall_hit.hitpointX,
                    hit_y: wall_hit.hitpointY
                }
            );
        }
    }


    // =====================================
    // NORMAL COLLISION ENEMIES
    // =====================================

    var enemy_list = ds_list_create();

    collision_line_list(
        start_x,
        start_y,
        end_x,
        end_y,
        oEnemy_TEMP,
        false,
        true,
        enemy_list,
        false
    );


    for (var i = 0; i < ds_list_size(enemy_list); i++)
    {
        var enemy = enemy_list[| i];

        if (instance_exists(enemy))
        {
            var dist = point_distance(
                start_x,
                start_y,
                enemy.x,
                enemy.y
            );

            var enemy_fraction = dist / _range;

            array_push(
                all_hits,
                {
                    instance: enemy,
                    type: "enemy",

                    fraction: enemy_fraction,

                    hit_x:
                        start_x
                        + lengthdir_x(
                            dist,
                            shoot_direction
                        ),

                    hit_y:
                        start_y
                        + lengthdir_y(
                            dist,
                            shoot_direction
                        )
                }
            );
        }
    }

    ds_list_destroy(enemy_list);


    // =====================================
    // SORT CLOSEST -> FURTHEST
    // =====================================

    array_sort(
        all_hits,
        function(a, b)
        {
            return a.fraction - b.fraction;
        }
    );


    // =====================================
    // PIERCING
    // =====================================

    var max_hits = _piercing + 1;

    var amount_to_process = min(
        array_length(all_hits),
        max_hits
    );


    // =====================================
    // DAMAGE / PROCESS OBJECTS
    // =====================================

    for (var i = 0; i < amount_to_process; i++)
    {
        var hit = all_hits[i];
        var inst = hit.instance;


        if (!instance_exists(inst))
        {
            continue;
        }


        // -----------------------------
        // ENEMY
        // -----------------------------

        if (hit.type == "enemy")
        {
            enemy.ehp -= _damage;
			enemy.hit_timer = 0.15;

            show_debug_message(
                "Enemy hit! HP: "
                + string(inst.ehp)
            );

            if (inst.ehp <= 0)
            {
                instance_destroy(inst);

                show_debug_message(
                    "Enemy killed!"
                );
            }
        }


        // -----------------------------
        // WALL
        // -----------------------------

        else if (hit.type == "wall")
        {
            show_debug_message(
                "Wall hit!"
            );
        }
    }


    // =====================================
    // WHERE DOES THE VISUAL STOP?
    // =====================================

    var final_x = end_x;
    var final_y = end_y;


    // Enough objects were hit to consume all piercing
    if (array_length(all_hits) >= max_hits)
    {
        var stopping_hit =
            all_hits[max_hits - 1];

        final_x = stopping_hit.hit_x;
        final_y = stopping_hit.hit_y;
    }


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
    shot.line_x2 = end_x;
    shot.line_y2 = end_y;
}



    shot.line_x2 = final_x;
    shot.line_y2 = final_y;
}
