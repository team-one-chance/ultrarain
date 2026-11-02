if (!broken)
{
    draw_self();

    var _is_secret = variable_instance_exists(id, "secret_hard_only")
        && secret_hard_only;

    var _locked = !variable_global_exists("game_difficulty")
        || global.game_difficulty != 2;

    if (_is_secret && _locked)
    {
        var _cx = (bbox_left + bbox_right) * 0.5;
        var _cy = (bbox_top + bbox_bottom) * 0.5;

        var _old_color = draw_get_color();
        var _old_alpha = draw_get_alpha();

        draw_set_alpha(1);

// Upper half of the lock shackle, 2 pixels thick.
draw_set_color(c_silver);

var _radius = 5;
var _shackle_y = _cy - 3;
var _segments = 12;

for (var _i = 0; _i < _segments; _i++)
{
    var _angle1 = 180 - 180 * _i / _segments;
    var _angle2 = 180 - 180 * (_i + 1) / _segments;

    draw_line_width(
        _cx + lengthdir_x(_radius, _angle1),
        _shackle_y + lengthdir_y(_radius, _angle1),
        _cx + lengthdir_x(_radius, _angle2),
        _shackle_y + lengthdir_y(_radius, _angle2),
        2
    );
}

        // Lock body.
        draw_set_color(make_color_rgb(220, 170, 50));
        draw_rectangle(_cx - 7, _cy - 3, _cx + 7, _cy + 7, false);

        // Keyhole.
        draw_set_color(c_black);
        draw_circle(_cx, _cy + 1, 1, false);
        draw_rectangle(_cx - 1, _cy + 1, _cx + 1, _cy + 4, false);

        draw_set_color(_old_color);
        draw_set_alpha(_old_alpha);
    }
}