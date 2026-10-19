image_speed = 0;

reader = noone;
reading = false;
player_near = false;

// Replace this with your ending message.
terminal_title = "ULTRARAIN — DEMO COMPLETE";

terminal_text =
    "You have reached the end of the ULTRARAIN demo."
    + "\n\n"
    + "Thank you for playing."
	terminal_display_text = terminal_text;

terminal_no_damage_text =
    "Huh..."
    + "\n"
    + "It seems you havent gotten damaged in the entire demo? Did you check out the secret area yet? maybe you have to look more carefully and explore more. they say that its only dark if you're not used to it.";

terminal_no_healing_text =
    "NO HEALING USED."
    + "\n"
    + "Impressive, But can you do it without taking damage at all?";
	
terminal_text_none =
    "You have reached the end of the ULTRARAIN demo."
    + "\n\n"
    + "Thank you for playing."
	+ "\n\n"
	+ "It seems you have missed something, maybe try doing a better job next time.";
	terminal_display_text = terminal_text;
	
	command_input = "";
command_feedback = "";
command_cursor_timer = 0;
command_result_sound = -1;
command_restart_pending = false;
stop_command_result_sfx = function()
{
    if (command_result_sound != -1 && audio_is_playing(command_result_sound))
    {
        audio_stop_sound(command_result_sound);
    }
    command_result_sound = -1;
};
