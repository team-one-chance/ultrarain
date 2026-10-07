player_near = false;

if (reading)
{
    if (!instance_exists(reader))
    {
        reading = false;
        reader = noone;
        exit;
    }

    if (keyboard_check_pressed(vk_escape)
    || keyboard_check_pressed(ord("E")))
    {
        if (reader.hacking_controller == id)
        {
            reader.hacking_controller = noone;
        }

        reader = noone;
        reading = false;
    }

    exit;
}

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
		else if (global.demo_took_damage && global.demo_used_healing)
		{
			terminal_display_text = terminal_text_none;
		}

        // Reuse the existing player interaction lock.
        reader.hacking_controller = id;
        reader.phy_speed_x = 0;
        reader.phy_speed_y = 0;
    }
}