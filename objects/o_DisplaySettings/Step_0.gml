// Reapply the saved profile after room changes and surface loss.
display_settings_apply();

// F11 switches between fullscreen and windowed mode.
if (keyboard_check_pressed(vk_f11))
{
    window_set_fullscreen(!window_get_fullscreen());
}

if (menu_exhibition_active() && !window_get_fullscreen())
{
    window_set_fullscreen(true);
}
