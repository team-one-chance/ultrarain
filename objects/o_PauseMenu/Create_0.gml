opened = false;
pickup_notice_pending = ""; // Item key queued by a pickup collision; empty means no pending modal.
pickup_notice_key = ""; // Item key displayed until the player explicitly closes its panel.
page = 0;
selected = 0;
selection_age = 0;
menu_age = 0;
last_mouse_x = device_mouse_x_to_gui(0);
last_mouse_y = device_mouse_y_to_gui(0);
accent = make_color_rgb(0, 186, 225);
controller = noone;
controls_page = 0;
controls_capture = ""; // Action awaiting a keyboard or mouse binding, or empty.
if (!variable_global_exists("exhibition_exit_locked")) global.exhibition_exit_locked = false;
if (!variable_global_exists("heal_mouse_combo")) global.heal_mouse_combo = false; // Optional two-button healing input.

pause_options = function()
{
    switch (page)
    {
        case 1: return ["Fullscreen: " + (window_get_fullscreen() ? "On" : "Off"),
            "Pixelization: " + (menu_pixelization_active() ? "On" : "Off"),
            "Mouse combo heal: " + (global.heal_mouse_combo ? "On" : "Off"), "Controls", "Back"];
        case 2: return ["Back"];
        case 3: return controls_menu_options(controls_page, controls_capture);
    }
    return ["Resume", "Restart from Checkpoint", "Restart Level", "Settings", "Credits", "Exit to Main Menu"];
};

pause_layout = function()
{
    var _scale = min(1.5, display_get_gui_width() / 850, display_get_gui_height() / 650);
    var _height = 540 * _scale;
    return { x: display_get_gui_width() * 0.5,
        top: (display_get_gui_height() - _height) * 0.5,
        width: 600 * _scale, height: _height, scale: _scale,
        row_height: (page == 3 ? 40 : 54) * _scale, row_top: (display_get_gui_height() - _height) * 0.5 + 150 * _scale };
};

pickup_notice_layout = function()
{
    var _scale = min(1.35, display_get_gui_width() / 1000, display_get_gui_height() / 600); // GUI scale; keeps the larger panel within the screen.
    var _width = 720 * _scale; // GUI pixels at scale 1; wider than the former 440-pixel notice.
    var _height = 380 * _scale; // GUI pixels at scale 1; room for a large icon and readable instructions.
    var _x = display_get_gui_width() * 0.5;
    var _top = (display_get_gui_height() - _height) * 0.5;
    return { x: _x, top: _top, width: _width, height: _height, scale: _scale,
        left: _x - _width * 0.5, right: _x + _width * 0.5,
        button_left: _x - 130 * _scale, button_right: _x + 130 * _scale,
        button_top: _top + 310 * _scale, button_bottom: _top + 354 * _scale };
};

pause_resume = function()
{
    opened = false;
    pickup_notice_key = "";
    if (instance_exists(controller))
    {
        controller.thaw_world();
        controller.update_time();
    }
    global.dev_resume_input = true;
    keyboard_clear(vk_enter);
    keyboard_clear(vk_escape);
    mouse_clear(mb_left);
};

pause_new_run = function(_destination, _retry = undefined)
{
    pause_resume();
    global.demo_travel_state = undefined;
    global.demo_took_damage = false;
    global.demo_used_healing = false;
    global.demo_finish_time = 0;
    global.tutorial_checkpoint_retry = _retry;
    global.menu_checkpoint = _retry;
    global.menu_launch_room = _destination;
    global.menu_saved_fullscreen = window_get_fullscreen();
    keyboard_string = "";
    // Clear every stored room, including rooms visited through seamless travel.
    game_restart();
};

pause_activate = function()
{
    if (page == 1)
    {
        if (selected == 0) window_set_fullscreen(!window_get_fullscreen());
        else if (selected == 1) menu_toggle_pixelization();
        else if (selected == 2) global.heal_mouse_combo = !global.heal_mouse_combo;
        else if (selected == 3) { page = 3; selected = 0; controls_page = 0; }
        else { page = 0; selected = 3; }
        selection_age = 0;
        return;
    }
    if (page == 2)
    {
        page = 0;
        selected = 4;
        selection_age = 0;
        return;
    }
    if (page == 3)
    {
        var _names = controls_names();
        var _count = min(8, array_length(_names) - controls_page * 8);
        if (selected < _count) controls_capture = _names[controls_page * 8 + selected];
        else if (selected == _count) { controls_page = (controls_page + ceil(array_length(_names) / 8) - 1) mod ceil(array_length(_names) / 8); selected = 0; }
        else if (selected == _count + 1) { controls_page = (controls_page + 1) mod ceil(array_length(_names) / 8); selected = 0; }
        else if (selected == _count + 2) { global.controls_bindings = controls_defaults(); controls_save(); }
        else { page = 1; selected = 3; }
        selection_age = 0;
        return;
    }
    switch (selected)
    {
        case 0: pause_resume(); break;
        case 1:
            // Activate the checkpoint controller before reading its room-local data.
            pause_resume();
            if (room == LE_TUTORIAL_WIP && instance_exists(o_TutorialCheckpoint))
            {
                var _checkpoint = instance_find(o_TutorialCheckpoint, 0);
                global.tutorial_checkpoint_retry = {
                    x: _checkpoint.respawn_x, y: _checkpoint.respawn_y,
                    cleared: _checkpoint.big_room_cleared, layers: _checkpoint.checkpoint_layers,
                    first_door_open: _checkpoint.checkpoint_first_door_open || _checkpoint.first_door_is_open()
                };
                global.demo_travel_state = undefined;
                with (o_SeamlessTravel)
                {
                    pending = undefined;
                    transition_cooldown = 0;
                    if (variable_instance_exists(id, "physics_visited_rooms"))
                    {
                        var _key = room_get_name(room);
                        if (variable_struct_exists(physics_visited_rooms, _key))
                            variable_struct_remove(physics_visited_rooms, _key);
                    }
                }
                room_persistent = false;
                room_restart();
            }
            else if (variable_global_exists("menu_checkpoint") && is_struct(global.menu_checkpoint))
                pause_new_run(LE_TUTORIAL_WIP, global.menu_checkpoint);
            else pause_new_run(room == TESTING ? TESTING : LE_TUTORIAL_WIP);
            break;
        case 2: pause_new_run(room == TESTING ? TESTING : LE_TUTORIAL_WIP); break;
        case 3: page = 1; selected = 0; selection_age = 0; break;
        case 4: page = 2; selected = 0; selection_age = 0; break;
        case 5: pause_new_run(undefined); break;
    }
};
