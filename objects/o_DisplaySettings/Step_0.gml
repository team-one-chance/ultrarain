// F11 switches between fullscreen and windowed mode.
if (keyboard_check_pressed(vk_f11))
{
    window_set_fullscreen(!window_get_fullscreen());
}