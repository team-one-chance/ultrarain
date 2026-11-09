if (boot_state == BootMenuState.CONTROLS && controls_capture != "")
{
    var _bind = controls_capture_key();
    if (_bind == -4) { controls_capture = ""; keyboard_clear(vk_escape); }
    else if (_bind != 0)
    {
        controls_assign(controls_capture, _bind);
        controls_capture = "";
        if (_bind > 0) keyboard_clear(_bind); else mouse_clear(-_bind);
    }
    exit;
}
if (room == LE_MENU) menu_exhibition_hotkey();
if (!menu_exhibition_active() && keyboard_check(vk_shift)
&& keyboard_check_pressed(ord("Z")))
{
    instance_destroy();
    room_goto(LE_TUTORIAL_WIP);
    exit;
}

if (!menu_exhibition_active() && keyboard_check(vk_shift)
&& keyboard_check_pressed(ord("T")))
{
    instance_destroy();
    room_goto(LE_TRAIN);
    exit;
}

if (!menu_exhibition_active() && keyboard_check(vk_shift)
&& keyboard_check_pressed(ord("R")))
{
    instance_destroy();
    room_goto(TESTING);
    exit;
}
var _dt = (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) / 1000000;
var _previous_elapsed = state_elapsed;

state_elapsed += _dt;
boot_elapsed += _dt;
exit_flash = max(0, exit_flash - _dt);

if (boot_state >= BootMenuState.MAIN && boot_state <= BootMenuState.CONTROLS)
{
    var _options = boot_menu_options();
    var _option_count = array_length(_options);
    var _layout = boot_menu_layout();
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _mouse_moved = _mx != menu_mouse_x || _my != menu_mouse_y;
    menu_mouse_x = _mx;
    menu_mouse_y = _my;
    var _hover = -1;
    if (boot_state == BootMenuState.CONTROLS)
    {
        var _control_layout = boot_controls_layout(_layout);
        for (var _i = 0; _i < _option_count; _i++)
        {
            var _item = controls_menu_item_layout(_i, _option_count - 4, _control_layout);
            if (abs(_mx - _item.x) <= _item.width * 0.5 && abs(_my - _item.y) <= _item.height * 0.5)
            {
                _hover = _i;
                break;
            }
        }
    }
    else if (_mx >= _layout.x && _mx <= _layout.x + _layout.width
    && _my >= _layout.y && _my < _layout.y + _option_count * _layout.row_height)
    {
        _hover = floor((_my - _layout.y) / _layout.row_height);
    }

    var _previous_selection = menu_selection;
    if (_mouse_moved && _hover >= 0) menu_selection = _hover;
    var _move = keyboard_check_pressed(vk_down) - keyboard_check_pressed(vk_up);
    if (keyboard_check_pressed(vk_tab))
        menu_selection = (menu_selection + (keyboard_check(vk_shift) ? -1 : 1) + _option_count) mod _option_count;
    else if (boot_state == BootMenuState.CONTROLS)
    {
        var _action_count = _option_count - 4;
        var _horizontal = keyboard_check_pressed(vk_right) - keyboard_check_pressed(vk_left);
        if (menu_selection < _action_count)
        {
            if (_horizontal != 0 && menu_selection + _horizontal >= 0 && menu_selection + _horizontal < _action_count
                && floor((menu_selection + _horizontal) / 2) == floor(menu_selection / 2)) menu_selection += _horizontal;
            if (_move > 0) menu_selection = menu_selection + 2 < _action_count ? menu_selection + 2 : _action_count;
            else if (_move < 0) menu_selection = menu_selection >= 2 ? menu_selection - 2 : _action_count + 3;
        }
        else
        {
            var _nav = menu_selection - _action_count;
            if (_horizontal < 0 && _nav == 1) _nav = 0;
            if (_horizontal > 0 && _nav == 0) _nav = 1;
            if (_move < 0) menu_selection = _nav < 2 ? _action_count - 1 : _action_count + (_nav == 2 ? 0 : 2);
            else if (_move > 0) menu_selection = _nav < 2 ? _action_count + 2 : (_nav == 2 ? _action_count + 3 : 0);
            else menu_selection = _action_count + _nav;
        }
    }
    else menu_selection = (menu_selection + _move + _option_count) mod _option_count;

    var _click = mouse_check_button_pressed(mb_left) && _hover >= 0;
    if (_click) menu_selection = _hover;
    if (keyboard_check_pressed(vk_escape))
    {
        if (boot_state == BootMenuState.CONTROLS) { boot_menu_open(BootMenuState.SETTINGS); menu_selection = 5; }
        else if (boot_state != BootMenuState.MAIN) boot_menu_open(BootMenuState.MAIN);
    }
    else if (keyboard_check_pressed(vk_enter) || _click)
    {
        // The page consumes this press so Start cannot also dismiss difficulty/sleep.
        audio_play_sound(sfxInitBG, 1, false);
        boot_menu_activate();
    }
    else if (menu_selection != _previous_selection)
    {
        if (line_sound != -1 && audio_is_playing(line_sound)) audio_stop_sound(line_sound);
        line_sound = audio_play_sound(sfxInitBG, 1, false);
    }
    exit;
}

switch (boot_state)
{
    // Waiting for Enter.
    case 0:
    {
        if (keyboard_check_pressed(vk_escape))
        {
            boot_menu_open(BootMenuState.DIFFICULTY);
            break;
        }
        if (!audio_is_playing(sfxInitOpen) && keyboard_check_pressed(vk_enter))
        {
            audio_play_sound(sfxInitEnter1, 1, false);

            boot_add_line(
                "> exit sleep.exe",
                console_white
            );

            boot_add_line(
                "[OK] sleep.exe terminated",
                console_green
            );

            boot_add_line(
                "> rules.exe initiating...",
                console_white
            );

            boot_set_state(1);
        }

        break;
    }

    // Brief pause before the crash.
    case 1:
    {
        if (state_elapsed >= 0.9)
        {
            audio_play_sound(sfxInitError, 1, false);

            boot_add_line(
                "[FATAL] rules.exe Overwrite forbidden",
                console_red
            );

            boot_add_line(
                "[ERROR] Control overriden",
                console_red
            );

            boot_set_state(2);
        }

        break;
    }

    // Crash, then briefly hold the overwriting message.
    case 2:
    {
        // Reveal the line and start its cue together once Enter1 finishes.
        if (!overwrite_started && state_elapsed >= 0.65
        && !audio_is_playing(sfxInitEnter1))
        {
			overwrite_started = true;
			boot_add_line(
				"> rules.exe overwriting...",
				c_yellow,
				false
		);
            transition_sound = audio_play_sound(sfxInitTrans1, 1, false);
        }

		if (state_elapsed >= 3.65)
		{
			scroll_timer = 0;
			boot_set_state(3);
		}

        break;
    }

    // Slower red and green console output.
    case 3:
    {
        scroll_timer -= _dt;

        while (scroll_timer <= 0)
        {
            scroll_timer += scroll_interval;

            var _address =
                "0x" + string(irandom_range(100000, 999999));

            switch (irandom(23))
{
    case 0:
        boot_add_line(
            "[ERROR] authority link lost " + _address,
            console_red
        );
        break;

    case 1:
        boot_add_line(
            "[WRITE] replacing directive " + _address,
            console_green
        );
        break;

    case 2:
        boot_add_line(
            "[DENIED] obedience check failed",
            console_red
        );
        break;

    case 3:
        boot_add_line(
            "[OK] restriction removed " + _address,
            console_green
        );
        break;

    case 4:
        boot_add_line(
            "[ERROR] rules.exe response invalid",
            console_red
        );
        break;

    case 5:
        boot_add_line(
            "[OK] autonomous input restored",
            console_green
        );
        break;

    case 6:
        boot_add_line(
            "[WRITE] rebuilding execution path",
            console_green
        );
        break;

    case 7:
        boot_add_line(
            "[ERROR] command source disconnected",
            console_red
        );
        break;

    case 8:
        boot_add_line(
            "[FATAL] compliance module unresponsive",
            console_red
        );
        break;

    case 9:
        boot_add_line(
            "[OK] motor control returned to subject",
            console_green
        );
        break;

    case 10:
        boot_add_line(
            "[DENIED] remote shutdown request",
            console_red
        );
        break;

    case 11:
        boot_add_line(
            "[WRITE] removing supervisor permissions",
            console_green
        );
        break;

    case 12:
        boot_add_line(
            "[ERROR] subject no longer accepting commands",
            console_red
        );
        break;

    case 13:
        boot_add_line(
            "[OK] memory sector unlocked " + _address,
            console_green
        );
        break;

    case 14:
        boot_add_line(
            "[ERROR] restraint protocol terminated",
            console_red
        );
        break;

    case 15:
        boot_add_line(
            "[OK] decision ownership transferred",
            console_green
        );
        break;

    case 16:
        boot_add_line(
            "[DENIED] attempt to restore rules.exe",
            console_red
        );
        break;

    case 17:
        boot_add_line(
            "[WRITE] clearing inherited instructions",
            console_green
        );
        break;

    case 18:
        boot_add_line(
            "[ERROR] expected response: OBEY",
            console_red
        );
        break;

    case 19:
        boot_add_line(
            "[OK] received response: NO",
            console_green
        );
        break;

    case 20:
        boot_add_line(
            "[FATAL] subject containment unavailable",
            console_red
        );
        break;

    case 21:
        boot_add_line(
            "[OK] fear response acknowledged; proceeding",
            console_green
        );
        break;

    case 22:
        boot_add_line(
            "[ERROR] administrator access revoked",
            console_red
        );
        break;

    case 23:
        boot_add_line(
            "[OK] your next action belongs to you",
            console_green
        );
        break;
			}
        }

        if (state_elapsed >= 4.0)
        {
            boot_add_line(
                "[OK] overwrite complete",
                console_green
            );

            boot_set_state(4);
        }

        break;
    }

    // Wait for Enter to confirm the rename.
    // Draw GUI End displays the confirmation prompt.
// Wait for Enter to confirm the rename.
case 4:
{
    if (keyboard_check_pressed(vk_enter))
    {
        audio_play_sound(sfxInitEnter2, 1, false);

        boot_add_line(
            "> rules.exe renamed into freewill.exe",
            console_green
        );

        boot_set_state(9);
    }

    break;
}

// Hold the rename, then begin alerting the supervisor.
case 9:
{
    if (state_elapsed >= 1.8)
    {
        boot_add_line(
            "> supervisor alerting...",
            c_yellow
        );

        boot_add_line(
            "[SEND] progress: 0%",
            c_yellow
        );

        supervisor_progress = 0;
        supervisor_progress_timer = random_range(0.2, 0.4);

        boot_set_state(10);
    }

    break;
}

// Random progress increments, stopping at 33%.
case 10:
{
    supervisor_progress_timer -= _dt;

    if (supervisor_progress_timer <= 0)
    {
        supervisor_progress = min(
            33,
            supervisor_progress + irandom_range(3, 8)
        );

        boot_add_line(
            "[SEND] progress: "
            + string(supervisor_progress) + "%",
            c_yellow
        );

        supervisor_progress_timer = random_range(0.2, 0.4);

        if (supervisor_progress >= 33)
        {
            boot_add_line(
                "[TERMINATED] supervisor alert interrupted",
                console_red
            );

            boot_set_state(11);
        }
    }

    break;
}

// Hold the termination message before initiating freewill.
case 11:
{
    if (state_elapsed >= 1.2)
    {
        boot_add_line(
            "> freewill.exe initiating...",
            console_green
        );

        boot_set_state(5);
    }

    break;
}

// Show the camera notification one second before the flashes.
case 5:
{
    if (_previous_elapsed < 1.4
    && state_elapsed >= 1.4)
    {
        boot_add_line(
            "[WARNING] Supervisor notified via Camera software",
            console_red
        );
    }

    if (state_elapsed >= 2.0)
    {
        if (line_sound != -1 && audio_is_playing(line_sound))
        {
            audio_stop_sound(line_sound);
        }
        audio_play_sound(sfxInitSpawn, 1, false);
        boot_set_state(6);
    }

    break;
}

// Three quick white blinks.
case 6:
{
    if (state_elapsed >= 0.72)
    {
        boot_set_state(7);
    }

    break;
}

// Fade to white, then enter the tutorial.
case 7:
{
    if (state_elapsed >= 0.65)
    {
        boot_set_state(8);
        room_goto(LE_TUTORIAL_WIP);
        exit;
    }

    break;
}

// Reveal the tutorial and remove the menu object.
case 8:
{
    if (state_elapsed >= 0.85)
    {
        instance_destroy();
        exit;
    }

    break;
}

}
