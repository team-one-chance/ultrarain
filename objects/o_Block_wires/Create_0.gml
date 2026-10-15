player = noone;

// Electrical bursts. Distances are in room pixels; times are in seconds.
wire_arc_reach = 27;
wire_arc_count = random_range(3, 10); // Simultaneous arcs per burst; 0 disables arcs.
wire_burst_interval_min = 0.15;
wire_burst_interval_max = 0.5;
wire_burst_timer = random_range(wire_burst_interval_min, wire_burst_interval_max);
wire_arcs = [];


// =====================================
// GET STRETCHED SIZE
// =====================================

// Fit the fixture to the sprite's collision bounds,
// accounting for its origin and signed scale.
var _left =
    (sprite_get_bbox_left(sprite_index)
    - sprite_get_xoffset(sprite_index)) * image_xscale;

var _right =
    (sprite_get_bbox_right(sprite_index) + 1
    - sprite_get_xoffset(sprite_index)) * image_xscale;

var _top =
    (sprite_get_bbox_top(sprite_index)
    - sprite_get_yoffset(sprite_index)) * image_yscale;

var _bottom =
    (sprite_get_bbox_bottom(sprite_index) + 1
    - sprite_get_yoffset(sprite_index)) * image_yscale;

// One room pixel of extra forgiveness on each edge.
var _half_w = max(0.5, abs(_right - _left) * 0.5 - 1);
var _half_h = max(0.5, abs(_bottom - _top) * 0.5 - 1);

var fix = physics_fixture_create();

physics_fixture_set_box_shape(fix, _half_w, _half_h);
physics_fixture_set_density(fix, 0);

// Detect contact without pushing the player or coin away.
physics_fixture_set_sensor(fix, true);
physics_fixture_set_collision_group(fix, 0);

physics_fixture_bind_ext(
    fix,
    id,
    (_left + _right) * 0.5,
    (_top + _bottom) * 0.5
);

physics_fixture_delete(fix);

wire_contact_lights = [];

wire_contact_effect = function(_target, _is_player)
{
    if (!instance_exists(_target)) return;
    if (abs(image_xscale) < 0.001
    || abs(image_yscale) < 0.001) return;

    var _cos = dcos(image_angle);
    var _sin = dsin(image_angle);

    var _left = sprite_get_bbox_left(sprite_index)
        - sprite_get_xoffset(sprite_index);

    var _right = sprite_get_bbox_right(sprite_index)
        - sprite_get_xoffset(sprite_index);

    var _top = sprite_get_bbox_top(sprite_index)
        - sprite_get_yoffset(sprite_index);

    var _bottom = sprite_get_bbox_bottom(sprite_index)
        - sprite_get_yoffset(sprite_index);

    var _count = _is_player ? 8 : 1;
    var _duration = _is_player ? 0.28 : 0.16;

    repeat (_count)
    {
        var _tx = _is_player
            ? random_range(_target.bbox_left, _target.bbox_right)
            : (_target.bbox_left + _target.bbox_right) * 0.5;

        var _ty = _is_player
            ? random_range(_target.bbox_top, _target.bbox_bottom)
            : (_target.bbox_top + _target.bbox_bottom) * 0.5;

        // Convert the target into the wire sprite's local coordinates.
        var _dx = _tx - x;
        var _dy = _ty - y;

        var _local_x = (_dx * _cos - _dy * _sin) / image_xscale;
        var _local_y = (_dx * _sin + _dy * _cos) / image_yscale;

        var _anchor_x = clamp(_local_x, _left, _right);
        var _anchor_y = _top;

        if (sprite_index == exposedwires_left)
        {
            _anchor_x = _left;
            _anchor_y = clamp(_local_y, _top, _bottom);
        }
        else if (sprite_index == exposedwires_right)
        {
            _anchor_x = _right;
            _anchor_y = clamp(_local_y, _top, _bottom);
        }

        var _scaled_x = _anchor_x * image_xscale;
        var _scaled_y = _anchor_y * image_yscale;

        var _sx = x + _scaled_x * _cos + _scaled_y * _sin;
        var _sy = y - _scaled_x * _sin + _scaled_y * _cos;

        var _direction = point_direction(_sx, _sy, _tx, _ty);
        var _points = [{ x: 0, y: 0 }];

        for (var _segment = 1; _segment <= 7; _segment++)
        {
            var _t = _segment / 7;
            var _jitter = _segment == 7
                ? 0 : random_range(-5, 5);

            array_push(_points, {
                x: (_tx - _sx) * _t
                    + lengthdir_x(_jitter, _direction + 90),
                y: (_ty - _sy) * _t
                    + lengthdir_y(_jitter, _direction + 90)
            });
        }

        array_push(wire_arcs, {
            anchor_x: _anchor_x,
            anchor_y: _anchor_y,
            points: _points,
            life: _duration,
            duration: _duration
        });
    }

    // Only player contact creates the strong lighting flash.
    if (_is_player)
    {
        var _light = instance_create_depth(
            (_target.bbox_left + _target.bbox_right) * 0.5,
            (_target.bbox_top + _target.bbox_bottom) * 0.5,
            depth,
            o_PointLight,
            {
                light_enabled: true,
                light_radius: 180,
                light_strength: 0.9,
                light_color: make_color_rgb(190, 225, 255)
            }
        );

        array_push(wire_contact_lights, {
            light: _light,
            life: 0.22,
            duration: 0.22
        });
    }
};