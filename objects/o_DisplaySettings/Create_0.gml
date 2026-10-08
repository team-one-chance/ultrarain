// Prevent duplicate display controllers.
if (instance_number(o_DisplaySettings) > 1)
{
    instance_destroy();
    exit;
}

persistent = true;

// Color of the space outside the game image.
window_set_colour(c_black);

window_set_fullscreen(true);