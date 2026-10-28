// Regression controller for the REAL effect and configuration, run by GameMaker.
persistent = true; // Carry assertions across the two test rooms.
test_phase = 0; // 0 = first room render, 1 = change rooms, 2 = second room setup, 3 = second render, 4 = exit.
failure_count = 0; // Nonzero fails the external runner check.
global.dev_delta_time = 0; // Freeze simulation while inspecting deterministic animation ages.
global.dev_freecam = false; // Exercise normal and freecam drawing explicitly.

check = function(_condition, _description)
{
    if (!_condition) failure_count++;
    show_debug_message((_condition ? "BREAKER_TEST_PASS: " : "BREAKER_TEST_FAIL: ") + _description);
};

var _settings = breaker_slam_visual_settings(); // The same live struct used in gameplay.
_settings.radius_pixels = 128; // Deliberately exceed the old 64-pixel cap.
_settings.duration_seconds = 1.2; // Deliberately exceed the old fixed 0.22-second ribbon animation.
_settings.wind_colour = c_lime; // Pure green makes actual rendered-color checks unambiguous.
_settings.shade_colour = c_lime;
_settings.wind_height_pixels = 30;
_settings.wind_width_pixels = 8;
_settings.dust_count = 0; // Inspect gust pixels independently of random dust.
_settings.flash_duration_fraction = 0; // Inspect gust pixels independently of the flash.
_settings.opacity = 1;

test_effect = instance_create_depth(96, 100, 0, oBreakerSlamVFX); // The gameplay object, without a test-specific implementation.
test_effect.effect_age_seconds = 0.6; // Halfway through the configured duration, after the old animation would have ended.

render_has_extended_green_wind = function()
{
    var _surface = surface_create(320, 160); // Offscreen render target for actual GPU pixel checks.
    var _camera = camera_create_view(0, 0, 320, 160); // Pixel-aligned camera matching the render target.
    var _old_world = matrix_get(matrix_world);
    var _old_view = matrix_get(matrix_view);
    var _old_projection = matrix_get(matrix_projection);
    surface_set_target(_surface);
    camera_apply(_camera);
    draw_clear_alpha(c_black, 1);
    test_effect.draw_pressure_burst();
    surface_reset_target();
    matrix_set(matrix_world, _old_world);
    matrix_set(matrix_view, _old_view);
    matrix_set(matrix_projection, _old_projection);
    var _found = false; // Green beyond x=160 proves both configured color and spread reached the GPU.
    for (var _pixel_x = 162; _pixel_x < 225 && !_found; _pixel_x += 2)
    {
        for (var _pixel_y = 62; _pixel_y < 103; _pixel_y += 2)
        {
            var _colour = surface_getpixel(_surface, _pixel_x, _pixel_y);
            if (colour_get_green(_colour) > 20 && colour_get_red(_colour) < 5 && colour_get_blue(_colour) < 5)
            {
                _found = true;
                break;
            }
        }
    }
    camera_destroy(_camera);
    surface_free(_surface);
    return _found;
};
