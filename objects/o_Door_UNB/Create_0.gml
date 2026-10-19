door_state = 0; // 0 = closed, 1 = opening, 2 = open
boarding_lock_owner = noone;

//train_exit = true;

image_index = 0;
image_speed = 0;

// Permanent trim in sprite-local coordinates; it stays after the panels retract.
var _frame_w = sprite_get_width(sprite_index);
var _frame_h = sprite_get_height(sprite_index);
var _frame_dark = make_color_rgb(20, 22, 24);
var _frame_metal = make_color_rgb(70, 74, 78);
var _frame_edge = make_color_rgb(160, 165, 170);
var _frame_mark = make_color_rgb(220, 205, 100);
door_frame_rects = [
    // Dark outer casing and recessed steel rails.
    [-3, -4, 3, _frame_h, _frame_dark],
    [_frame_w - 3, -4, _frame_w + 3, _frame_h, _frame_dark],
    [-3, -4, _frame_w + 3, 2, _frame_dark],
    [-2, -3, 2, _frame_h, _frame_metal],
    [_frame_w - 2, -3, _frame_w + 2, _frame_h, _frame_metal],
    [-2, -3, _frame_w + 2, 0, _frame_metal],
    // Thin bevels keep the doorway readable against dark backgrounds.
    [-2, -3, -1, _frame_h, _frame_edge],
    [1, 0, 2, _frame_h, _frame_edge],
    [_frame_w - 2, 0, _frame_w - 1, _frame_h, _frame_edge],
    [_frame_w + 1, -3, _frame_w + 2, _frame_h, _frame_edge],
    [-2, -3, _frame_w + 2, -2, _frame_edge],
    [2, 0, _frame_w - 2, 1, _frame_edge],
    // Flat threshold: a visual border without adding a collision obstacle.
    [2, _frame_h - 2, _frame_w - 2, _frame_h, _frame_dark],
    [2, _frame_h - 1, _frame_w - 2, _frame_h, _frame_edge],
    // Small safety marks and mounting bolts match the door's industrial art.
    [-1, 3, 1, 7, _frame_mark],
    [_frame_w - 1, 3, _frame_w + 1, 7, _frame_mark],
    [-1, _frame_h - 8, 1, _frame_h - 4, _frame_mark],
    [_frame_w - 1, _frame_h - 8, _frame_w + 1, _frame_h - 4, _frame_mark],
    [-1, 11, 1, 13, _frame_dark],
    [_frame_w - 1, 11, _frame_w + 1, 13, _frame_dark],
    [-1, _frame_h - 14, 1, _frame_h - 12, _frame_dark],
    [_frame_w - 1, _frame_h - 14, _frame_w + 1, _frame_h - 12, _frame_dark]
];

// Render each side separately so the player can pass between the jambs.
door_draw_frame = function(_foreground)
{
    var _xx = dcos(image_angle) * image_xscale;
    var _xy = -dsin(image_angle) * image_xscale;
    var _yx = dsin(image_angle) * image_yscale;
    var _yy = dcos(image_angle) * image_yscale;
    var _origin_x = sprite_get_xoffset(sprite_index);
    var _origin_y = sprite_get_yoffset(sprite_index);
    var _width = sprite_get_width(sprite_index);

    draw_primitive_begin(pr_trianglelist);
    for (var _i = 0; _i < array_length(door_frame_rects); _i++)
    {
        var _rect = door_frame_rects[_i];
        // Split crossing trim too, preserving the corner bevels on each side.
        // Keep the screen-right jamb in front even on mirrored doors.
        var _left = _rect[0];
        var _right = _rect[2];
        if ((_xx >= 0) == _foreground)
        {
            _left = max(_left, (_xx >= 0) ? _width - 3 : 3);
        }
        else
        {
            _right = min(_right, (_xx >= 0) ? _width - 3 : 3);
        }
        if (_right <= _left) continue;

        _left -= _origin_x;
        _right -= _origin_x;
        var _top = _rect[1] - _origin_y;
        var _bottom = _rect[3] - _origin_y;
        var _color = make_color_rgb(
            color_get_red(_rect[4]) * color_get_red(image_blend) / 255,
            color_get_green(_rect[4]) * color_get_green(image_blend) / 255,
            color_get_blue(_rect[4]) * color_get_blue(image_blend) / 255
        );

        var _x1 = x + _left * _xx + _top * _yx;
        var _y1 = y + _left * _xy + _top * _yy;
        var _x2 = x + _right * _xx + _top * _yx;
        var _y2 = y + _right * _xy + _top * _yy;
        var _x3 = x + _left * _xx + _bottom * _yx;
        var _y3 = y + _left * _xy + _bottom * _yy;
        var _x4 = x + _right * _xx + _bottom * _yx;
        var _y4 = y + _right * _xy + _bottom * _yy;

        draw_vertex_color(_x1, _y1, _color, image_alpha);
        draw_vertex_color(_x2, _y2, _color, image_alpha);
        draw_vertex_color(_x3, _y3, _color, image_alpha);
        draw_vertex_color(_x2, _y2, _color, image_alpha);
        draw_vertex_color(_x4, _y4, _color, image_alpha);
        draw_vertex_color(_x3, _y3, _color, image_alpha);
    }
    draw_primitive_end();
};

door_frame_front = instance_create_depth(x, y, depth - 1, o_DoorFrameFront, {door_owner: id});

var door_width = 32;  // CHANGE: blocking panel width
var door_height = 64; // CHANGE: blocking panel height

var fix = physics_fixture_create();

physics_fixture_set_box_shape(
    fix,
    door_width / 2,
    door_height / 2
);

physics_fixture_set_density(fix, 0);
physics_fixture_set_friction(fix, 0.5);
physics_fixture_set_restitution(fix, 0);
physics_fixture_set_collision_group(fix, 1);

// Place the rectangle at the sprite canvas centre,
// regardless of where you set the sprite origin.
door_fixture = physics_fixture_bind_ext(
    fix,
    id,
    sprite_get_width(sprite_index) / 2 - sprite_get_xoffset(sprite_index),
    sprite_get_height(sprite_index) / 2 - sprite_get_yoffset(sprite_index)
);

physics_fixture_delete(fix);

door_open = function()
{
    if (door_state != 0) return;
    if (instance_exists(boarding_lock_owner)
    && !boarding_lock_owner.train_boarding_unlocked()) return;

    door_state = 1;
    world_sfx_play(sfxDoorOpen, x, y, 0.75);
    image_index = 0;
    image_speed = 1;
};

// 3 = closing
door_close = function()
{
	show_debug_message(
    "Door closing requested. State: "
    + string(door_state)
);
    if (door_state != 2) return;

    // Restore the closed door's collision.
    if (door_fixture == -1)
    {
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

    door_state = 3;
    world_sfx_play(sfxDoorClose, x, y, 0.75);
    image_index = image_number - 1;
    image_speed = -1;
};
