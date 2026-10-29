

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
if (player_near && controls_pressed("interact"))
{
    if (controller_state == 0)
    {
        controller_state = 1;
        audio_play_sound(sfxHijackTerminalStart, 1, false);
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
if (player_near && controls_pressed("interact"))
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
        audio_play_sound(sfxHijackTerminal, 1, false);
        hacker = _player;
        hacker.hacking_controller = id;

        // For now, pair this controller with the nearest door.
        linked_door = instance_nearest(x, y, o_Door_UNB);

        wire_connections = [-1, -1, -1, -1];
        wire_connect_flash = [0, 0, 0, 0];
        wire_complete_timer = 0;
        // Use each color exactly once on each side.
        left_order = [0, 1, 2, 3];
        right_order = [0, 1, 2, 3];
        drag_wire = -1;

        // Independently shuffle both sides without introducing duplicates.
        for (var i = 3; i > 0; i--)
        {
            var j = irandom(i);
            var temporary = left_order[i];
            left_order[i] = left_order[j];
            left_order[j] = temporary;

            j = irandom(i);
            temporary = right_order[i];
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
        stop_wire_flash_sfx();
        drag_wire = -1;
    }
    else
    {
        for (var i = 0; i < 4; i++)
        {
            wire_connect_flash[i] = max(0, wire_connect_flash[i] - _dt);
        }

        // Keep the last successful connection visible before closing the panel.
        if (wire_complete_timer > 0)
        {
            wire_complete_timer = max(0, wire_complete_timer - _dt);
            if (wire_complete_timer == 0)
            {
                hacker.hacking_controller = noone;
                hacker = noone;
                controller_state = 3;
                stop_wire_flash_sfx();

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
            exit;
        }

        // Briefly reveal the colors at irregular intervals.
        wire_flash_timer -= _dt;
        wire_flash_time = max(0, wire_flash_time - _dt);

        if (wire_flash_timer <= 0)
        {
            wire_flash_time = 0.22;
            wire_flash_timer = random_range(1.1, 1.8);
        }

        // Use the same on/off state as the sockets, including after a pause.
        if (wire_flash_time > 0)
        {
            if (wire_flash_sound == -1 || !audio_is_playing(wire_flash_sound))
            {
                wire_flash_sound = audio_play_sound(sfxBlinkingLights, 1, false);
            }
        }
        else
        {
            stop_wire_flash_sfx();
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
    wire_connect_flash[drag_wire] = wire_connect_flash_duration;
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
                wire_complete_timer = wire_connect_flash_duration;
                wire_flash_time = 0;
                stop_wire_flash_sfx();
            }
        }
    }
}
