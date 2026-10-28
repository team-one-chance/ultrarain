if (test_phase == 1)
{
    test_phase = 2;
    room_goto(SLAM_REGRESSION_NEXT);
    exit;
}
if (test_phase == 2 && room == SLAM_REGRESSION_NEXT)
{
    var _settings = breaker_slam_visual_settings(); // Re-enter through the real settings getter after a room change.
    check(_settings.radius_pixels == 128, "radius survives room change");
    check(_settings.duration_seconds == 1.2, "duration survives room change");
    check(_settings.wind_colour == c_lime, "color survives room change");
    test_effect = instance_create_depth(96, 100, 0, oBreakerSlamVFX);
    test_effect.effect_age_seconds = 0.6;
    test_phase = 3;
}
if (test_phase == 4)
{
    global.dev_delta_time = 20000; // Advance exactly 0.02 seconds for lifetime boundary checks.
    test_effect.effect_age_seconds = 0.5;
    with (test_effect) event_perform(ev_step, 0);
    check(instance_exists(test_effect), "effect survives beyond the old fixed lifetime");
    test_effect.effect_age_seconds = 1.19;
    with (test_effect) event_perform(ev_step, 0);
    check(!instance_exists(test_effect), "effect ends at configured lifetime");
    show_debug_message("BREAKER_TEST_COMPLETE: failures=" + string(failure_count));
    game_end();
}
