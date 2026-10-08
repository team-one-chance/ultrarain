

// Check whether the player is close enough to interact.
var _player = instance_nearest(x, y, o_Player);
player_near = false;

if (instance_exists(_player))
{
    player_near =
        point_distance(x, y, _player.x, _player.y - 32) <= 52
        && instance_nearest(
            _player.x,
            _player.y - 32,
            o_DoorController
        ) == id;
}


// First E breaks the controller.
// Second E starts the wire puzzle.
if (player_near && keyboard_check_pressed(ord("E")))
{
    if (controller_state == 0)
    {
        controller_state = 1;
        sprite_index = broken_sprite;
        image_index = 0;
        image_speed = 0;
        spark_timer = 0;

        exit; // stop this Step event after breaking the panel
    }
    else if (controller_state == 1)
    {
        // Keep your existing minigame-start code here.
    }
}


// Emit three falling sparks per burst at irregular intervals.
if (controller_state >= 1)
{
    spark_timer -= (variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000;

    if (spark_timer <= 0)
    {
        var _spark_x =
            x + sprite_get_width(sprite_index) / 2
              - sprite_get_xoffset(sprite_index);

        var _spark_y =
            y + sprite_get_height(sprite_index) / 2
              - sprite_get_yoffset(sprite_index);

repeat (3)
{
    _spark_x =
        x + (
            irandom(sprite_get_width(sprite_index) - 1)
            - sprite_get_xoffset(sprite_index)
        ) * image_xscale;

    _spark_y =
        y + (
            irandom(sprite_get_height(sprite_index) - 1)
            - sprite_get_yoffset(sprite_index)
        ) * image_yscale;

    instance_create_depth(
        _spark_x,
        _spark_y,
        depth - 1,
        o_TerminalSpark
    );
}

        spark_timer = random_range(0.35, 1.1);
    }
}

var _dt = (variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000;
_player = instance_nearest(x, y, o_Player);

player_near = false;

if (instance_exists(_player))
{
    player_near =
        point_distance(x, y, _player.x, _player.y - 32) <= 52
        && instance_nearest(
            _player.x, _player.y - 32, o_DoorController
        ) == id;
}


// Interact with the controller.
if (player_near && keyboard_check_pressed(ord("E")))
{
    if (controller_state == 0)
    {
        controller_state = 1;
        sprite_index = broken_sprite;
        image_index = 0;
        image_speed = 0;
        spark_timer = 0;
    }
    else if (controller_state == 1)
    {
        controller_state = 2;
        hacker = _player;
        hacker.hacking_controller = id;

        // For now, pair this controller with the nearest door.
        linked_door = instance_nearest(x, y, o_Door_UNB);

        wire_connections = [-1, -1, -1, -1];
// Each wire independently gets a random color.
// 0 = green, 1 = yellow, 2 = blue, 3 = red.
left_order = [
    irandom(3),
    irandom(3),
    irandom(3),
    irandom(3)
];

// Same colors on the right, shuffled by the existing code.
right_order = [
    left_order[0],
    left_order[1],
    left_order[2],
    left_order[3]
];
        drag_wire = -1;

        // Shuffle the four right-side sockets.
        for (var i = 3; i > 0; i--)
        {
            var j = irandom(i);
            var temporary = right_order[i];
            right_order[i] = right_order[j];
            right_order[j] = temporary;
        }

        wire_flash_timer = 0.4;
        wire_flash_time = 0;
    }
}


// Broken controller: bursts of three falling sparks.
if (controller_state >= 1)
{
    spark_timer -= _dt;

    if (spark_timer <= 0)
    {
        repeat (3)
        {
            var _spark_x =
                x + (
                    irandom(sprite_get_width(sprite_index) - 1)
                    - sprite_get_xoffset(sprite_index)
                ) * image_xscale;

            var _spark_y =
                y + (
                    irandom(sprite_get_height(sprite_index) - 1)
                    - sprite_get_yoffset(sprite_index)
                ) * image_yscale;

            instance_create_depth(
                _spark_x, _spark_y,
                depth - 1,
                o_TerminalSpark
            );
        }

        spark_timer = random_range(0.35, 1.1);
    }
}


// Everything below applies only while the puzzle is open.
if (controller_state == 2)
{
    if (!instance_exists(hacker)
    || keyboard_check_pressed(vk_escape))
    {
        if (instance_exists(hacker))
        {
            hacker.hacking_controller = noone;
        }

        hacker = noone;
        controller_state = 1;
        drag_wire = -1;
    }
    else
    {
        // Briefly reveal the colors at irregular intervals.
        wire_flash_timer -= _dt;
        wire_flash_time = max(0, wire_flash_time - _dt);

        if (wire_flash_timer <= 0)
        {
            wire_flash_time = 0.22;
            wire_flash_timer = random_range(1.1, 1.8);
        }

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

        var _mx = device_mouse_x_to_gui(0);
        var _my = device_mouse_y_to_gui(0);

        // Start dragging from an unconnected left socket.
        if (mouse_check_button_pressed(mb_left))
        {
            for (var i = 0; i < 4; i++)
            {
                var _left_y = _first_y + i * _row_gap;

                if (wire_connections[i] == -1
                && point_distance(
                    _mx, _my, _left_x, _left_y
                ) <= 26)
                {
                    drag_wire = i;
                    break;
                }
            }
        }

        // Release over a matching right socket.
        if (mouse_check_button_released(mb_left)
        && drag_wire != -1)
        {
            for (var row = 0; row < 4; row++)
            {
                var _right_y = _first_y + row * _row_gap;

                if (point_distance(
                    _mx, _my, _right_x, _right_y
                ) <= 26)
                {
// A right socket can only accept one wire.
var _occupied = false;

for (var k = 0; k < 4; k++)
{
    if (wire_connections[k] == row)
    {
        _occupied = true;
        break;
    }
}

if (!_occupied
&& right_order[row] == left_order[drag_wire])
{
    wire_connections[drag_wire] = row;
}

                    break;
                }
            }

            drag_wire = -1;

            // Check whether all four wires are connected.
            var _complete = true;

            for (var i = 0; i < 4; i++)
            {
                if (wire_connections[i] == -1)
                {
                    _complete = false;
                    break;
                }
            }

            if (_complete)
            {
                hacker.hacking_controller = noone;
                hacker = noone;
                controller_state = 3;

                if (instance_exists(linked_door))
                {
                    with (linked_door)
                    {
                        door_open();
                    }
                }
                else
                {
                    show_debug_message(
                        "Wire puzzle complete, but no door was found"
                    );
                }
            }
        }
    }
}