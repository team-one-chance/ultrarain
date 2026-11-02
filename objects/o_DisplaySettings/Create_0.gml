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

if (variable_global_exists("menu_saved_fullscreen") && !is_undefined(global.menu_saved_fullscreen))
{
    window_set_fullscreen(global.menu_saved_fullscreen);
    global.menu_saved_fullscreen = undefined;
}
else window_set_fullscreen(true);
