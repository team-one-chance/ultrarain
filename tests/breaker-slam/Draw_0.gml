if (test_phase == 0 || test_phase == 3)
{
    var _is_next_room = test_phase == 3; // Label the actual room-transition render check.
    check(render_has_extended_green_wind(), _is_next_room
        ? "rendered color, radius, and duration in next room"
        : "rendered color, radius, and duration in TESTING");
    var _settings = breaker_slam_visual_settings();
    _settings.opacity = 0;
    check(!render_has_extended_green_wind(), "zero opacity hides the configured gust");
    _settings.opacity = 1;
    check(!test_effect.defer_to_lighting, "room without lighting draws effect directly");

    // Exercise the real effect's draw handoff using a minimal renderer resource.
    view_enabled = true;
    var _camera = camera_create_view(0, 0, 320, 160);
    var _old_camera = view_camera[0];
    view_camera[0] = _camera;
    var _lighting = instance_create_depth(0, 0, 100, o_Lighting);
    _lighting.enabled = false;
    _lighting.light_surface = surface_create(320, 160);
    with (test_effect) event_perform(ev_draw, 0);
    check(!test_effect.defer_to_lighting, "disabled lighting uses direct drawing");
    _lighting.enabled = true;
    _lighting.visible = false;
    with (test_effect) event_perform(ev_draw, 0);
    check(!test_effect.defer_to_lighting, "invisible lighting uses direct drawing");
    _lighting.visible = true;
    global.dev_freecam = true;
    with (test_effect) event_perform(ev_draw, 0);
    check(!test_effect.defer_to_lighting, "freecam uses direct drawing");
    global.dev_freecam = false;
    with (test_effect) event_perform(ev_draw, 0);
    check(test_effect.defer_to_lighting, "active lighting receives the effect for its post-ambient pass");
    surface_free(_lighting.light_surface);
    with (_lighting) instance_destroy();
    view_camera[0] = _old_camera;
    camera_destroy(_camera);
    view_enabled = false;
    test_phase = _is_next_room ? 4 : 1;
}
