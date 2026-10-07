if (keyboard_check(vk_shift)
&& keyboard_check_pressed(ord("Z")))
{
    instance_destroy();
    room_goto(LE_TUTORIAL_WIP);
    exit;
}

var _dt = delta_time / 1000000;
var _previous_elapsed = state_elapsed;

state_elapsed += _dt;
boot_elapsed += _dt;

switch (boot_state)
{
    // Waiting for Enter.
    case 0:
    {
        if (keyboard_check_pressed(vk_enter))
        {
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
        // Add this line only when crossing 0.65 seconds.
        if (_previous_elapsed < 0.65
        && state_elapsed >= 0.65)
        {
			boot_add_line(
				"> rules.exe overwriting...",
				c_yellow
		);
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