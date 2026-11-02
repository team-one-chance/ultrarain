global.training_check_frame++;
var _frame = global.training_check_frame;
if (_frame == 1)
{
    o_BootMenu.menu_selection = 0;
    o_BootMenu.boot_menu_activate();
}
if (_frame == 30)
{
    // Use temporary keyboard bindings to drive real player input paths, without saving controls.
    global.controls_bindings.coin = ord("C");
    global.controls_bindings.fire = ord("F");
    global.controls_bindings.slide = ord("V");
    global.controls_bindings.dash = ord("B");
    global.controls_bindings.slam = ord("N");
    o_TrainingSimulation.enter(2);
    o_Player.phy_position_x = 17520;
    o_Player.phy_position_y = 13920;
    keyboard_key_press(controls_key("right"));
    keyboard_key_press(controls_key("slide"));
}
if (_frame >= 31 && _frame < 150) keyboard_key_press(controls_key("right"));
if (_frame >= 31 && _frame < 80) keyboard_key_press(controls_key("slide"));
if (_frame >= 171 && _frame < 220) keyboard_key_press(controls_key("right"));
if (_frame == 80)
{
    show_debug_message("[TEST] slide x=" + string(o_Player.x) + " y=" + string(o_Player.y) + " sliding=" + string(o_Player.is_sliding) + " actions=" + json_stringify(o_TrainingSimulation.actions));
    check(o_TrainingSimulation.demonstrated("slide"), "Actual grounded slide emits objective event");
    check(o_Player.x > 17888, "Player can slide through authored low ceiling");
    keyboard_key_release(controls_key("slide"));
}
if (_frame == 100)
{
    o_Player.phy_position_x = 18180;
    o_Player.phy_position_y = 13920;
    o_Player.phy_speed_x = 0;
    o_Player.phy_speed_y = 0;
    keyboard_key_press(controls_key("jump"));
}
if (_frame == 103) keyboard_key_release(controls_key("jump"));
if (_frame == 104) keyboard_key_press(controls_key("dash"));
if (_frame == 106) keyboard_key_release(controls_key("dash"));
if (_frame == 130)
{
    check(o_TrainingSimulation.demonstrated("jump"), "Actual jump emits event");
    show_debug_message("[TEST] air x=" + string(o_Player.x) + " y=" + string(o_Player.y) + " actions=" + json_stringify(o_TrainingSimulation.actions));
    check(o_TrainingSimulation.demonstrated("air_dash"), "Actual air dash emits event");
    o_Player.phy_position_x = 18800;
    o_Player.phy_position_y = 13920;
    o_Player.phy_speed_x = 0;
    o_Player.phy_speed_y = 0;
}
if (_frame == 140) keyboard_key_press(controls_key("dash"));
if (_frame == 142) keyboard_key_release(controls_key("dash"));
if (_frame == 150)
{
    check(o_TrainingSimulation.demonstrated("ground_dash"), "Actual ground dash emits event");
    keyboard_key_release(controls_key("right"));
    o_Player.phy_position_x = 20340;
    o_Player.phy_position_y = 13920;
}
if (_frame == 160) check(o_TrainingSimulation.section == 3, "Movement demonstrations and end trigger advance");
if (_frame == 170)
{
    o_Player.phy_position_x = 23953;
    o_Player.phy_position_y = 13950;
    o_Player.phy_speed_x = 0;
    o_Player.phy_speed_y = 0;
    keyboard_key_press(controls_key("right"));
}
if (_frame == 220)
{
    check(o_TrainingSimulation.demonstrated("wall"), "Actual wall contact/hold emits event");
    keyboard_key_release(controls_key("right"));
    o_Player.phy_position_x = 24720;
    o_Player.phy_position_y = 16320;
    o_Player.phy_speed_x = 0;
    o_Player.phy_speed_y = 0;
}
if (_frame == 222) keyboard_key_press(controls_key("slam"));
if (_frame == 224) keyboard_key_release(controls_key("slam"));
if (_frame == 340)
{
    show_debug_message("[TEST] slam section=" + string(o_TrainingSimulation.section) + " x=" + string(o_Player.x) + " y=" + string(o_Player.y));
    check(o_TrainingSimulation.section == 4, "Actual slam breaks floor and descends into pistol area");
    check(instance_number(o_Block_Breakable) == 0, "All five floor segments break through gameplay");
    check(instance_number(o_TrainingTarget) == 4, "Arrival slam does not consume pistol targets");
    o_TrainingSimulation.enter(7);
    coin_stage = 0; coin_phase_time = 0; coin_section = 7;
}

if (_frame == 343) keyboard_key_press(controls_key("pistol"));
if (_frame == 345) keyboard_key_release(controls_key("pistol"));

// Repeated actual inputs; physics is suspended only to hold the aiming target still.
if (_frame >= 350 && training_active())
{
    var _section = o_TrainingSimulation.section;
    if (_section == 7 || _section == 8)
    {
        if (coin_section != _section)
        {
            check(_section == 8, "Three real pistol-to-coin traces complete direct-hit exercise");
            coin_stage = 0; coin_phase_time = 0; coin_section = _section;
            keyboard_key_release(controls_key("fire"));
        }
        coin_phase_time++;
        if (coin_stage == 0)
        {
            keyboard_key_press(controls_key("coin"));
            coin_stage = 1; coin_phase_time = 0;
        }
        else if (coin_stage == 1 && coin_phase_time >= 4)
        {
            keyboard_key_release(controls_key("coin"));
            var _coin = instance_find(o_Coin, 0);
            check(instance_exists(_coin), "Coin input spawns player-owned coin");
            if (instance_exists(_coin))
            {
                _coin.phy_active = false;
                _coin.x = _section == 7 ? o_Player.x + 40 : 18480;
                _coin.y = _section == 7 ? o_Player.y - 120 : 16360;
            }
            coin_stage = 2; coin_phase_time = 0;
        }
        else if (coin_stage == 2)
        {
            var _coin = instance_find(o_Coin, 0);
            if (instance_exists(_coin))
            {
                var _cam = view_camera[0];
                var _scale = min(window_get_width() / surface_get_width(application_surface), window_get_height() / surface_get_height(application_surface));
                window_mouse_set((window_get_width() - surface_get_width(application_surface) * _scale) / 2
                    + (_coin.x - camera_get_view_x(_cam)) / camera_get_view_width(_cam) * surface_get_width(application_surface) * _scale,
                    (window_get_height() - surface_get_height(application_surface) * _scale) / 2
                    + (_coin.y - camera_get_view_y(_cam)) / camera_get_view_height(_cam) * surface_get_height(application_surface) * _scale);
                if (coin_phase_time >= 8) keyboard_key_press(controls_key("fire"));
            }
            else
            {
                keyboard_key_release(controls_key("fire"));
                coin_stage = 0; coin_phase_time = 0;
            }
        }
    }
    if (_section == 9)
    {
        check(true, "Repeated real coin ricochets defeat target behind authored wall");
        keyboard_key_release(controls_key("fire"));
        keyboard_key_release(controls_key("coin"));
        show_debug_message("[TEST] MECHANICS COMPLETE");
        game_end();
    }
}
if (_frame > 940)
{
    check(false, "Mechanics test timed out");
    show_debug_message("[TEST] timed out section=" + string(o_TrainingSimulation.section)
        + " hits=" + string(o_TrainingSimulation.coin_hits));
    game_end();
}
