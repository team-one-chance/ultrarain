left_order = [0, 1, 2, 3];
controller_state = 0;
// 0 = intact, 1 = broken, 2 = hacking

broken_sprite = s_Terminal;

image_index = 0;
image_speed = 0;

player_near = false;
spark_timer = 0;

controller_state = 0;
// 0 = intact, 1 = broken, 2 = hacking, 3 = completed

broken_sprite = s_Terminal;
image_index = 0;
image_speed = 0;

player_near = false;
spark_timer = 0;
hacker = noone;
linked_door = noone;

// Color IDs: 0 green, 1 yellow, 2 blue, 3 red.
wire_colors = [c_lime, c_yellow, c_blue, c_red];
right_order = [0, 1, 2, 3];

// For each left wire, stores its connected right row.
// -1 means unconnected.
wire_connections = [-1, -1, -1, -1];

drag_wire = -1;
wire_flash_timer = 0;
wire_flash_time = 0;

wire_flash_sound = -1;
stop_wire_flash_sfx = function()
{
    if (wire_flash_sound != -1 && audio_is_playing(wire_flash_sound))
    {
        audio_stop_sound(wire_flash_sound);
    }
    wire_flash_sound = -1;
};
