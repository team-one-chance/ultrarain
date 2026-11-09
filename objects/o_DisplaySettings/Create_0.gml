// Prevent duplicate display controllers.
if (instance_number(o_DisplaySettings) > 1)
{
    instance_destroy();
    exit;
}

persistent = true;

// Nearest-neighbor sampling keeps world sprites and the scaled game image crisp.
gpu_set_texfilter(false);

// Color of the space outside the game image.
window_set_colour(c_black);

// Rooms render at 2160 x 720 (3:1); window scaling never increases render resolution.
// Keep the authored 1080-pixel GUI height while extending its horizontal space.
display_set_gui_size(3240, 1080);
var _window_height = max(1, floor(min(720, min(display_get_width() * 0.9 / 3,
    display_get_height() * 0.9)))); // Fit inside 90% of the display, including room for borders.
window_set_size(_window_height * 3, _window_height);
window_center();

if (variable_global_exists("menu_saved_fullscreen") && !is_undefined(global.menu_saved_fullscreen))
{
    window_set_fullscreen(global.menu_saved_fullscreen);
    global.menu_saved_fullscreen = undefined;
}
else window_set_fullscreen(true);
