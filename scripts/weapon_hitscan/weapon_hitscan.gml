function weapon_hitscan(_damage, _range, _piercing)
{
    // =====================================
    // AIM AT MOUSE
    // =====================================

    var shoot_direction = point_direction(
        x,
        y,
        mouse_x,
        mouse_y
    );

    var start_x = x;
    var start_y = y;


    // =====================================
    // FIND WALL DISTANCE
    // =====================================

    var wall_distance = raycast_wall_distance(
        start_x,
        start_y,
        shoot_direction,
        _range
    );


    // =====================================
    // CALCULATE SHOOT ENDPOINT
    // =====================================

    var end_x = start_x + lengthdir_x(
        wall_distance,
        shoot_direction
    );

    var end_y = start_y + lengthdir_y(
        wall_distance,
        shoot_direction
    );


    // =====================================
    // FIND ENEMIES ALONG THE RAY
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


    // =====================================
    // FIND CLOSEST ENEMIES
    // =====================================

    var enemy_data = [];

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

            array_push(enemy_data, {
                instance: enemy,
                distance: dist
            });
        }
    }

    ds_list_destroy(enemy_list);


    // =====================================
    // SORT ENEMIES BY DISTANCE
    // =====================================

    array_sort(
        enemy_data,
        function(a, b)
        {
            return a.distance - b.distance;
        }
    );


    // =====================================
    // DAMAGE ENEMIES
    // =====================================
    var max_targets = _piercing + 1;
    var targets_hit = 0;

    for (var i = 0; i < array_length(enemy_data); i++)
    {
        if (targets_hit >= max_targets)
        {
            break;
        }

        var enemy = enemy_data[i].instance;

        if (instance_exists(enemy))
        {
            enemy.ehp -= _damage;

            show_debug_message(
                "Hit enemy! HP remaining: " + string(enemy.ehp)
            );

            if (enemy.ehp <= 0)
            {
                instance_destroy(enemy);

                show_debug_message("Enemy killed!");
            }

            targets_hit++;
        }
    }


    // =====================================
    // CREATE YELLOW VISUAL
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
