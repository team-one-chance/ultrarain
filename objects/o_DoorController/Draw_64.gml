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

    // Wires and sockets.
    for (var i = 0; i < 4; i++)
    {
        var _left_y = _first_y + i * _row_gap;
        var _right_y = _first_y + i * _row_gap;

        // Connected wire, or wire being dragged.
        if (wire_connections[i] != -1)
        {
            var _target_y =
                _first_y + wire_connections[i] * _row_gap;

            draw_set_color(c_gray);
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
                device_mouse_x_to_gui(0),
                device_mouse_y_to_gui(0),
                3
            );
        }

        // Normally gray; flash the real color briefly.
var _left_color = c_gray;
var _right_color = c_gray;

// Check whether this right socket has a wire connected.
var _right_connected = false;

for (var k = 0; k < 4; k++)
{
    if (wire_connections[k] == i)
    {
        _right_connected = true;
        break;
    }
}

// Connected sockets stay colored.
// Unconnected sockets still flash.
if (wire_connections[i] != -1 || wire_flash_time > 0)
{
    _left_color = wire_colors[left_order[i]];
}

if (_right_connected || wire_flash_time > 0)
{
    _right_color = wire_colors[right_order[i]];
}
if (_right_connected || wire_flash_time > 0)
{
    _right_color = wire_colors[right_order[i]];
}

        draw_set_color(_left_color);
        draw_circle(_left_x, _left_y, 14, false);

        draw_set_color(_right_color);
        draw_circle(_right_x, _right_y, 14, false);
    }

    draw_set_color(c_white);
}