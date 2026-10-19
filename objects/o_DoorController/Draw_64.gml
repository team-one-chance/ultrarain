if (controller_state == 2)
{
    var _gui_w = display_get_gui_width();
    var _gui_h = display_get_gui_height();

    var _panel_w = min(380, _gui_w - 24);
    var _panel_h = min(280, _gui_h - 24);
    var _panel_x = (_gui_w - _panel_w) / 2;
    var _panel_y = (_gui_h - _panel_h) / 2;

    var _left_x = _panel_x + _panel_w * 0.22;
    var _right_x = _panel_x + _panel_w * 0.78;
    var _first_y = _panel_y + 64;
    var _row_gap = (_panel_h - 100) / 3;

    // Darken the game behind the panel.
    draw_set_color(c_black);
    draw_set_alpha(0.7);
    draw_rectangle(0, 0, _gui_w, _gui_h, false);
    draw_set_alpha(1);

    // Panel.
    draw_set_color(make_color_rgb(18, 22, 28));
    draw_rectangle(
        _panel_x, _panel_y,
        _panel_x + _panel_w, _panel_y + _panel_h,
        false
    );

    draw_set_color(c_white);
    draw_rectangle(
        _panel_x, _panel_y,
        _panel_x + _panel_w, _panel_y + _panel_h,
        true
    );

draw_set_halign(fa_center);

var _title = "RECONNECT POWER";
var _hint = "Drag wires to matching sparks   |   ESC to exit";
var _text_x = _gui_w / 2;
var _title_y = _panel_y + 18;
var _hint_y = _panel_y + _panel_h - 25;

// Black outline, 1 GUI pixel thick.
draw_set_color(c_black);

for (var _ox = -1; _ox <= 1; _ox++)
{
    for (var _oy = -1; _oy <= 1; _oy++)
    {
        if (_ox == 0 && _oy == 0) continue;

        draw_text(_text_x + _ox, _title_y + _oy, _title);
        draw_text(_text_x + _ox, _hint_y + _oy, _hint);
    }
}

// White text over the outline.
draw_set_color(c_white);
draw_text(_text_x, _title_y, _title);
draw_text(_text_x, _hint_y, _hint);

draw_set_halign(fa_left);

    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);

    // Draw wires first so they cannot cover socket highlights.
    for (var i = 0; i < 4; i++)
    {
        var _left_y = _first_y + i * _row_gap;

        // Connected wire, or wire being dragged.
        if (wire_connections[i] != -1)
        {
            var _target_y =
                _first_y + wire_connections[i] * _row_gap;

            var _wire_color = wire_colors[left_order[i]];
            var _flash = wire_connect_flash[i] / wire_connect_flash_duration;
            draw_set_color(_wire_color);
            draw_set_alpha(0.18 + 0.3 * _flash);
            draw_line_width(
                _left_x, _left_y,
                _right_x, _target_y,
                9
            );
            draw_set_alpha(1);
            draw_set_color(merge_color(_wire_color, c_white, _flash));
            draw_line_width(
                _left_x, _left_y,
                _right_x, _target_y,
                3
            );
        }
        else if (drag_wire == i)
        {
            draw_set_color(c_gray);
            draw_line_width(
                _left_x, _left_y,
                _mx, _my,
                3
            );
        }

    }

    for (var i = 0; i < 4; i++)
    {
        var _socket_y = _first_y + i * _row_gap;
        var _left_connected = wire_connections[i] != -1;
        var _right_connected = false;
        var _right_flash = 0;

        for (var k = 0; k < 4; k++)
        {
            if (wire_connections[k] == i)
            {
                _right_connected = true;
                _right_flash = wire_connect_flash[k];
                break;
            }
        }

        // Share the same feedback on both endpoints of a completed pair.
        for (var _side = 0; _side < 2; _side++)
        {
            var _socket_x = (_side == 0) ? _left_x : _right_x;
            var _connected = (_side == 0) ? _left_connected : _right_connected;
            var _color_id = (_side == 0) ? left_order[i] : right_order[i];
            var _flash = ((_side == 0) ? wire_connect_flash[i] : _right_flash)
                / wire_connect_flash_duration;
            var _hovered = point_distance(_mx, _my, _socket_x, _socket_y) <= 26;
            var _selected = _side == 0 && drag_wire == i;
            var _socket_color = (_connected || wire_flash_time > 0)
                ? wire_colors[_color_id] : c_gray;

            // Neutral hover feedback preserves the puzzle's hidden colors.
            if (_hovered || _selected)
            {
                draw_set_color(c_white);
                draw_set_alpha(0.18);
                draw_circle(_socket_x, _socket_y, 24, false);
                draw_set_alpha(1);
                draw_circle(_socket_x, _socket_y, 22, true);
                draw_circle(_socket_x, _socket_y, 23, true);
            }

            if (_flash > 0)
            {
                draw_set_color(c_white);
                draw_set_alpha(_flash);
                draw_circle(_socket_x, _socket_y, 18 + 10 * (1 - _flash), true);
                draw_set_alpha(0.35 * _flash);
                draw_circle(_socket_x, _socket_y, 21, false);
                draw_set_alpha(1);
            }

            draw_set_color(merge_color(_socket_color, c_white, _flash));
            draw_circle(_socket_x, _socket_y, 14, false);

            if (_connected)
            {
                draw_set_color(c_white);
                draw_circle(_socket_x, _socket_y, 17, true);
            }
        }
    }

    draw_set_color(c_white);
}
