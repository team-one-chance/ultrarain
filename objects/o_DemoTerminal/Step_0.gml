player_near = false;

// Handle reading and command input.
if (reading)
{
    if (!instance_exists(reader))
    {
        reading = false;
        reader = noone;
        keyboard_string = "";
        exit;
    }

    command_cursor_timer += (variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000;

    if (keyboard_check_pressed(vk_escape))
    {
        if (reader.hacking_controller == id)
        {
            reader.hacking_controller = noone;
        }

        reader = noone;
        reading = false;
        keyboard_string = "";
        exit;
    }

    // Capture typing, including Backspace.
    keyboard_string = string_copy(keyboard_string, 1, 64);
    command_input = keyboard_string;

    if (keyboard_check_pressed(vk_enter))
    {
        if (string_lower(command_input)
            == "vrain initiate restart.exe")
        {
            reader.hacking_controller = noone;
            keyboard_string = "";

            global.demo_travel_state = undefined;
            global.demo_took_damage = false;
            global.demo_used_healing = false;
            global.demo_finish_time = 0;

            game_restart();
            exit;
        }
        else
        {
            command_feedback = "ERROR: command not recognized.";
            command_input = "";
            keyboard_string = "";
        }
    }

    exit;
}

// Check whether the player can open the terminal.
var _player = instance_nearest(x, y, o_Player);

if (instance_exists(_player))
{
    var _cx = (bbox_left + bbox_right) * 0.5;
    var _cy = (bbox_top + bbox_bottom) * 0.5;

    player_near = point_distance(
        _cx, _cy,
        _player.x, _player.y - 32
    ) <= 64;

    if (player_near
    && _player.hacking_controller == noone
    && keyboard_check_pressed(ord("E")))
    {
        reader = _player;
        reading = true;

        keyboard_string = "";
        command_input = "";
        command_feedback = "";
        command_cursor_timer = 0;

        terminal_display_text = terminal_text;

        if (!global.demo_took_damage)
        {
            terminal_display_text +=
                "\n\n" + terminal_no_damage_text;
        }
        else if (!global.demo_used_healing)
        {
            terminal_display_text +=
                "\n\n" + terminal_no_healing_text;
        }
        else
        {
            terminal_display_text = terminal_text_none;
        }

        // Lock normal player controls while reading.
        reader.hacking_controller = id;
        reader.phy_speed_x = 0;
        reader.phy_speed_y = 0;
    }
}