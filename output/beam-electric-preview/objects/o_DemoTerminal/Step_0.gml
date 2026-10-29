player_near = false;

// Handle reading and command input.
if (reading)
{
    if (!instance_exists(reader))
    {
        stop_command_result_sfx();
        command_restart_pending = false;
        reading = false;
        reader = noone;
        keyboard_string = "";
        exit;
    }

    command_cursor_timer += (variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000;

    // Let the accepted-command cue finish before restarting the game.
    if (command_restart_pending)
    {
        if (!audio_is_playing(command_result_sound))
        {
            reader.hacking_controller = noone;
            keyboard_string = "";
            global.demo_travel_state = undefined;
            global.demo_took_damage = false;
            global.demo_used_healing = false;
            global.demo_finish_time = 0;
            game_restart();
        }
        exit;
    }

    if (keyboard_check_pressed(vk_escape))
    {
        keyboard_clear(vk_escape); // Consume close so the pause menu cannot also open.
        if (reader.hacking_controller == id)
        {
            reader.hacking_controller = noone;
        }

        stop_command_result_sfx();
        reader = noone;
        reading = false;
        keyboard_string = "";
        exit;
    }

    // Choose independently for each typing key, including Backspace and Enter.
    for (var _key = 8; _key <= 226; _key++)
    {
        var _typing_key = _key == vk_backspace || _key == vk_enter || _key == vk_space
            || (_key >= 48 && _key <= 57)   // Number row.
            || (_key >= 65 && _key <= 90)   // Letters.
            || (_key >= 96 && _key <= 111)  // Numpad digits and operators.
            || (_key >= 186 && _key <= 192) // Punctuation.
            || (_key >= 219 && _key <= 222) || _key == 226;

        if (_typing_key && keyboard_check_pressed(_key))
        {
            audio_play_sound(choose(sfxTyping1, sfxTyping2, sfxTyping3, sfxTyping4), 1, false);
        }
    }

    if (os_type == os_linux)
    {
        // Use key presses on Linux: the runner may not populate keyboard_string.
        // Commands are case-insensitive ASCII, so collect letters in lowercase.
        for (var _letter = ord("A"); _letter <= ord("Z"); _letter++)
        {
            if (keyboard_check_pressed(_letter))
            {
                command_input += string_lower(chr(_letter));
            }
        }

        for (var _digit = ord("0"); _digit <= ord("9"); _digit++)
        {
            if (keyboard_check_pressed(_digit))
            {
                command_input += chr(_digit);
            }
        }

        if (keyboard_check_pressed(vk_space)) command_input += " ";
        // GameMaker's period key code, plus the numpad decimal key.
        if (keyboard_check_pressed(190) || keyboard_check_pressed(vk_decimal))
        {
            command_input += ".";
        }

        command_input = string_copy(command_input, 1, 64);
        if (keyboard_check_pressed(vk_backspace))
        {
            command_input = string_copy(command_input, 1, max(0, string_length(command_input) - 1));
        }
    }
    else
    {
        // Native text input handles keyboard layouts and Backspace elsewhere.
        keyboard_string = string_copy(keyboard_string, 1, 64);
        command_input = keyboard_string;
    }

    if (keyboard_check_pressed(vk_enter))
    {
        if (string_lower(command_input)
            == "vrain initiate restart.exe")
        {
            stop_command_result_sfx();
            command_result_sound = audio_play_sound(sfxTerminalValid, 1, false);
            command_restart_pending = true;
            command_feedback = "Command accepted. Restarting...";
            exit;
        }
        else
        {
            stop_command_result_sfx();
            command_result_sound = audio_play_sound(sfxTerminalInvalid, 1, false);
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
    && controls_pressed("interact"))
    {
        reader = _player;
        reading = true;
        command_restart_pending = false;

        keyboard_string = "";
        command_input = "";
        command_feedback = "";
        command_cursor_timer = 0;

var _difficulty = variable_global_exists("game_difficulty")
    ? global.game_difficulty
    : 1;

// Easy
if (_difficulty == 0)
{
    terminal_display_text =
        "You have reached the end of the ULTRARAIN demo."
        + "\n\n"
        + "Thank you for playing."
        + "\n\n"
        + "Ready for more? Try the demo on a harder difficulty.";
}
// Normal
else if (_difficulty == 1)
{
    terminal_display_text =
        "You have reached the end of the ULTRARAIN demo on Normal."
        + "\n\n"
        + "Good job making it this far."
        + "\n\n"
        + "Think you can handle more? Try Hard difficulty.";
}
// Hard
else
{
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
}

        // Lock normal player controls while reading.
        reader.hacking_controller = id;
        reader.phy_speed_x = 0;
        reader.phy_speed_y = 0;
    }
}
