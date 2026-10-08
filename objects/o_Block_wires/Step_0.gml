if (instance_exists(player))
{
    //x = player.x;
    //y = player.y + 20;
}

// Expire old arcs without creating persistent effect instances.
var _dt = min((variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000, 0.05);
for (var _i = array_length(wire_arcs) - 1; _i >= 0; _i--)
{
    wire_arcs[_i].life -= _dt;
    if (wire_arcs[_i].life <= 0)
    {
        array_delete(wire_arcs, _i, 1);
    }
}

wire_burst_timer -= _dt;
if (wire_burst_timer <= 0 && sprite_index != -1)
{
    repeat (max(0, floor(wire_arc_count)))
    {
        // Each arc gets its own emission point across the sprite.
        // Sprite-local anchors follow scaling and rotation when drawn.
        var _anchor_x = random(sprite_get_width(sprite_index))
            - sprite_get_xoffset(sprite_index);
        var _anchor_y = random(sprite_get_height(sprite_index))
            - sprite_get_yoffset(sprite_index);

        var _direction = random(360);
        var _reach = random_range(wire_arc_reach * 0.4, wire_arc_reach);
        var _points = [{ x: 0, y: 0 }];

        // A jagged path stays fixed for its brief flash, avoiding draw-time RNG.
        for (var _segment = 1; _segment <= 5; _segment++)
        {
            var _along = _reach * _segment / 5;
            var _jitter = (_segment == 5) ? 0 : random_range(-4, 4);
            array_push(_points, {
                x: lengthdir_x(_along, _direction)
                    + lengthdir_x(_jitter, _direction + 90),
                y: lengthdir_y(_along, _direction)
                    + lengthdir_y(_jitter, _direction + 90)
            });
        }

        var _life = random_range(0.06, 0.14);
        array_push(wire_arcs, {
            anchor_x: _anchor_x,
            anchor_y: _anchor_y,
            points: _points,
            life: _life,
            duration: _life
        });
    }

    wire_burst_timer = random_range(
        wire_burst_interval_min, wire_burst_interval_max
    );
}
