function menu_exhibition_active()
{
    return variable_global_exists("exhibition_exit_locked") && global.exhibition_exit_locked;
}

function menu_pixelization_active()
{
    return variable_global_exists("settings_pixelization") && global.settings_pixelization;
}

function menu_toggle_pixelization()
{
    global.settings_pixelization = !menu_pixelization_active();
    with (o_Lighting)
        pixelation_size = global.settings_pixelization ? pixelation_alternate_size : 1.0;
}

function menu_exhibition_hotkey()
{
    if (!keyboard_check(vk_control) || !keyboard_check(vk_shift)
    || !keyboard_check_pressed(vk_f10)) return;
    global.exhibition_exit_locked = !menu_exhibition_active();
    if (global.exhibition_exit_locked)
    {
        with (o_DevMenu) disable_tools();
        global.basher_tuner_open = false;
        global.basher_tuner_capture_mouse = false;
        global.basher_tuner_motion = 0;
    }
}
