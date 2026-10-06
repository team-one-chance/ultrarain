function drone_trace(_sx, _sy, _angle, _range, _include_player)
{
    var _ex = _sx + lengthdir_x(_range, _angle);
    var _ey = _sy + lengthdir_y(_range, _angle);

    var _objects = [
        o_Block,
        o_Door_UNB,
        o_Door_Breakable,
        o_Chute_Breakable
    ];

    if (_include_player)
    {
        array_push(_objects, o_Player);
    }

    var _hits = ds_list_create();

    collision_line_list(
        _sx, _sy, _ex, _ey,
        _objects,
        false, true,
        _hits, false
    );

    var _nearest = 1;
    var _hit = noone;

    for (var _i = 0; _i < ds_list_size(_hits); _i++)
    {
        var _inst = _hits[| _i];

        if (!instance_exists(_inst)) continue;

        // Broken doors no longer block the ray.
        if (variable_instance_exists(_inst, "door_take_damage"))
        {
            if (_inst.broken || _inst.break_requested)
            {
                continue;
            }
        }

        var _fraction = ray_bbox_fraction(
            _sx, _sy, _ex, _ey, _inst
        );

        if (_fraction >= 0 && _fraction <= _nearest)
        {
            _nearest = _fraction;
            _hit = _inst;
        }
    }

    ds_list_destroy(_hits);

    return {
        end_x: lerp(_sx, _ex, _nearest),
        end_y: lerp(_sy, _ey, _nearest),
        hit: _hit
    };
}