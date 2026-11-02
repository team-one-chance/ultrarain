global.training_check_frame++;
var _frame = global.training_check_frame;
if (_frame == 1) { o_BootMenu.menu_selection = 0; o_BootMenu.boot_menu_activate(); }
if (_frame == 30)
{
    aim_at = function(_x, _y)
    {
        var _cam = view_camera[0];
        var _scale = min(window_get_width() / surface_get_width(application_surface), window_get_height() / surface_get_height(application_surface));
        window_mouse_set((window_get_width() - surface_get_width(application_surface) * _scale) / 2
            + (_x - camera_get_view_x(_cam)) / camera_get_view_width(_cam) * surface_get_width(application_surface) * _scale,
            (window_get_height() - surface_get_height(application_surface) * _scale) / 2
            + (_y - camera_get_view_y(_cam)) / camera_get_view_height(_cam) * surface_get_height(application_surface) * _scale);
    };
    aim_target = function(_target)
    {
        if (instance_exists(_target)) aim_at((_target.bbox_left + _target.bbox_right) / 2, (_target.bbox_top + _target.bbox_bottom) / 2);
    };
    check(o_TrainingSimulation.ui_text_scale > 1 && o_TrainingSimulation.ui_prompt_scale > 1, "178.1 Larger text and button prompt scales");
    screen_save("/tmp/issue178-look.png");
    global.controls_bindings.fire = ord("F"); global.controls_bindings.coin = ord("C");
    global.controls_bindings.slide = ord("V"); global.controls_bindings.dash = ord("B");
    global.controls_bindings.sword = ord("Q"); global.controls_bindings.pistol = ord("P");
    global.controls_bindings.left = ord("A"); global.controls_bindings.right = ord("D");
}
if (_frame == 35)
{
    o_TrainingSimulation.enter(1);
    o_Player.phy_position_x = 15100; o_Player.phy_position_y = 14950;
    check(array_length(o_TrainingSimulation.section_geometry) == 1, "178.2 Abyss left boundary exists");
    check(!is_undefined(o_TrainingSimulation.teleport_marker()), "178.5 Abyss transfer has a world marker");
}
if (_frame >= 36 && _frame < 60) keyboard_key_press(controls_key("left"));
if (_frame == 60)
{
    keyboard_key_release(controls_key("left"));
    check(o_Player.x >= 15084, "178.2 Actual physics prevents drifting left out of abyss trigger");
    o_Player.phy_position_x = 15200; o_Player.phy_position_y = 15264;
    o_Player.phy_speed_x = 0; o_Player.phy_speed_y = 0; o_TrainingSimulation.snap_camera();
    check(array_length(input_prompt_actions("dash_jump")) == 2 && array_length(input_prompt_actions("air_dash")) == 2, "178.3 Combined dash and jump prompts use both bindings");
}
if (_frame == 63) screen_save("/tmp/issue178-transfer.png");
if (_frame == 64)
{
    o_TrainingSimulation.enter(2);
    o_TrainingSimulation.actions = { slide: true, air_dash: true, ground_dash: true };
    o_Player.phy_position_x = 18160; o_Player.phy_position_y = 13920;
}
if (_frame == 65)
{
    check(o_TrainingSimulation.prompt == "air_dash", "178.3 Gap reminder remains visible after an earlier air dash");
    o_Player.phy_position_x = 18736; o_Player.phy_position_y = 13920;
}
if (_frame == 66)
{
    check(o_TrainingSimulation.prompt == "dash_jump", "178.3 Long-gap reminder combines dash and jump after earlier demonstrations");
    o_Player.phy_position_x = 20300; o_Player.phy_position_y = 13920;
    o_Player.player_set_collider(true); o_Player.is_sliding = true; o_Player.slide_direction = 1;
    keyboard_key_press(controls_key("right")); keyboard_key_press(controls_key("slide"));
}
if (_frame >= 66 && _frame < 68)
{
    keyboard_key_press(controls_key("right")); keyboard_key_press(controls_key("slide"));
}
if (_frame == 68) { keyboard_key_release(controls_key("right")); keyboard_key_release(controls_key("slide")); }
if (_frame == 70)
{
    check(o_TrainingSimulation.section == 3, "178.4 Sliding footprint activates dash exit");
    check(!o_Player.player_collider_short && !o_Player.is_sliding && !o_Player.dash_active, "178.4 Teleport clears slide and dash state");
    check(abs(o_Player.phy_position_x - 23504) < 40, "178.4 Teleport restores authored wallhold spawn");
    show_debug_message("[TEST] camera=" + string(camera_get_view_x(view_camera[0])) + " player=" + string(o_Player.x) + " physics=" + string(o_Player.phy_position_x) + " width=" + string(camera_get_view_width(view_camera[0])) + " generation=" + string(o_TrainingSimulation.generation));
    check(abs(camera_get_view_x(view_camera[0]) - (o_Player.x - camera_get_view_width(view_camera[0]) / 2)) < 40, "178.4 Camera snaps to destination");
    check(o_TrainingSimulation.prompt != "slam", "178.9 Slam prompt is absent at wallhold entrance");
}
if (_frame == 75)
{
    o_Player.phy_position_x = 23850; o_Player.phy_position_y = 14020;
    o_Player.phy_speed_x = 0; o_Player.phy_speed_y = 15;
}
if (_frame == 90)
{
    check(instance_exists(o_TrainingSimulation.wall_gate) && o_Player.y <= 14081, "178.6 Falling down the middle cannot bypass wallhold gate");
    check(!o_TrainingSimulation.demonstrated("wall"), "178.6 Falling is not wallholding");
}
if (_frame == 95)
{
    o_Player.phy_position_x = 23953; o_Player.phy_position_y = 13920;
    o_Player.phy_speed_x = 0; o_Player.phy_speed_y = 0;
}
if (_frame >= 95 && _frame < 150) keyboard_key_press(controls_key("right"));
if (_frame == 100) check(!o_TrainingSimulation.demonstrated("wall"), "178.6 A brief wall brush cannot complete the objective");
if (_frame == 150)
{
    keyboard_key_release(controls_key("right"));
    check(o_TrainingSimulation.demonstrated("wall") && !instance_exists(o_TrainingSimulation.wall_gate), "178.6 Sustained actual wallhold releases gate");
    check(o_TrainingSimulation.prompt != "slam", "178.9 Wallhold confirmation keeps descent prompt until the floor");
}
if (_frame == 155)
{
    o_TrainingSimulation.enter(3);
    check(array_length(o_TrainingSimulation.section_geometry) == 3, "178.6/8 Retry replaces gate and pillar collider without duplicates");
    check(collision_point(24240, 13500, o_Block, false, true) != noone, "178.8 Painted pillar has a right-face collider");
    o_Player.phy_position_x = 24288; o_Player.phy_position_y = 13520;
    o_Player.phy_speed_y = 0;
}
if (_frame >= 155 && _frame < 175) keyboard_key_press(controls_key("left"));
if (_frame == 175)
{
    keyboard_key_release(controls_key("left"));
    check(o_Player.x >= 24269, "178.8 Actual movement cannot enter pillar from right");
    o_TrainingSimulation.actions.wall = true;
    if (instance_exists(o_TrainingSimulation.wall_gate)) with (o_TrainingSimulation.wall_gate) instance_destroy();
    o_Player.phy_position_x = 23850; o_Player.phy_position_y = 16100;
}
if (_frame == 180)
{
    check(o_TrainingSimulation.prompt != "slam", "178.9 Slam prompt stays out of descent shaft");
    o_Player.phy_position_x = 24580; o_Player.phy_position_y = 16416;
    o_Player.phy_speed_x = 0; o_Player.phy_speed_y = 0;
    o_TrainingSimulation.snap_camera();
}
if (_frame == 190)
{
    check(o_TrainingSimulation.prompt == "slam", "178.9 Slam prompt appears beside authored breakable floor");
    var _floor = o_TrainingSimulation.floor_blocks[0];
    check(layer_get_name(_floor.layer) == "Instances" && _floor.depth < layer_get_depth("tiles_middleground"), "178.7 Breakables draw in front of middleground");

}
if (_frame == 200)
{
    screen_save("/tmp/issue178-floor.png");
    o_TrainingSimulation.enter(4);
    check(array_length(o_TrainingSimulation.section_geometry) == 2, "178.10 Pistol firing area has player-only side barriers");
}
if (_frame >= 205 && _frame < 230) keyboard_key_press(controls_key("right"));
if (_frame == 230)
{
    keyboard_key_release(controls_key("right"));
    check(o_Player.x <= 24787, "178.10 Player cannot walk out of pistol firing area");
}
if (_frame >= 210 && _frame < 400 && o_TrainingSimulation.section == 4)
{
    var _target = noone;
    for (var _i = 2; _i >= 0; --_i)
        if (!o_TrainingSimulation.targets[_i].defeated) { _target = o_TrainingSimulation.targets[_i].actor; break; }
    if (_target == noone && !o_TrainingSimulation.targets[3].defeated) _target = o_TrainingSimulation.targets[3].actor;
    aim_target(_target);
    if (_frame >= 220) keyboard_key_press(controls_key("fire"));
}
if (_frame == 410)
{
    keyboard_key_release(controls_key("fire"));
    check(o_TrainingSimulation.section == 5, "178.10 Actual pistol fire kills all four targets through barriers");
}
if (_frame == 412) keyboard_key_press(controls_key("sword"));
if (_frame == 414) keyboard_key_release(controls_key("sword"));
if (_frame == 416) keyboard_key_press(controls_key("coin"));
if (_frame == 418)
{
    keyboard_key_release(controls_key("coin"));
    check(o_Player.parry_timer > 0, "178.12 Actual sword parry works before coins unlock and does not crash");
    check(instance_number(o_Coin) == 0, "178.12 Sword parry does not unlock pistol coins early");
}
if (_frame == 420) screen_save("/tmp/issue178-parry.png");
if (_frame == 430)
{
    o_Player.phy_position_x = 17940; o_Player.phy_position_y = 15776;
    o_Player.phy_speed_x = 0; o_Player.phy_speed_y = 0;
    o_TrainingSimulation.snap_camera();
}
if (_frame >= 430 && _frame < 500 && o_TrainingSimulation.stage == 1)
{
    aim_target(o_TrainingSimulation.targets[0].actor);
    if (_frame mod 20 == 0) keyboard_key_press(controls_key("fire"));
    if (_frame mod 20 == 2) keyboard_key_release(controls_key("fire"));
}
if (_frame == 500)
{
    keyboard_key_release(controls_key("fire"));
    check(o_TrainingSimulation.stage == 2, "178.10 First sword dummy still requires actual sword strikes");
    keyboard_key_press(controls_key("pistol"));
}
if (_frame == 502) keyboard_key_release(controls_key("pistol"));
if (_frame >= 510 && _frame < 650 && o_TrainingSimulation.section == 5 && o_TrainingSimulation.stage == 2)
{
    var _target = !o_TrainingSimulation.targets[1].defeated ? o_TrainingSimulation.targets[1].actor : o_TrainingSimulation.targets[0].actor;
    aim_target(_target);
    if (_frame >= 520) keyboard_key_press(controls_key("fire"));
}
if (_frame == 660)
{
    keyboard_key_release(controls_key("fire"));
    check(o_TrainingSimulation.section == 6, "178.10 Far follow-up sword-area target can be killed by real pistol fire");
    o_Player.phy_position_x = 20080; o_Player.phy_position_y = 17060;
    o_Player.phy_speed_y = -15;
}
if (_frame == 680)
{
    check(o_Player.y >= 17050, "178.11 Materials roof stops upward escape");
    check(camera_get_view_y(view_camera[0]) >= 16800, "178.11 Camera cannot expose neighboring course above materials");
    check(o_Player.bbox_top - camera_get_view_y(view_camera[0]) >= 160, "178.1/11 Materials camera leaves player clear of enlarged HUD");
    screen_save("/tmp/issue178-materials.png");
}
if (_frame == 683) keyboard_key_press(controls_key("sword"));
if (_frame == 685) keyboard_key_release(controls_key("sword"));
if (_frame == 686) keyboard_key_press(controls_key("coin"));
if (_frame == 688)
{
    keyboard_key_release(controls_key("coin"));
    check(o_Player.parry_timer > 0, "178.12 Parry remains safe alongside materials dummy");
}
if (_frame == 700)
{
    o_TrainingSimulation.enter(7);
    check(o_TrainingSimulation.stage == 0 && o_TrainingSimulation.prompt == "pistol", "178.13 Coin instruction first asks to equip pistol");
    check(string_pos("CHAIN", o_TrainingSimulation.objective) == 0, "178.14 Initial coin text does not reveal chains");
    o_Player.weapon_type = "pistol";
}
if (_frame == 702) keyboard_key_press(controls_key("coin"));
if (_frame == 704)
{
    keyboard_key_release(controls_key("coin"));
    check(instance_number(o_Coin) == 0 && o_TrainingSimulation.stage == 0, "178.13 Coin step waits for demonstrated pistol selection");
}
if (_frame == 706) keyboard_key_press(controls_key("pistol"));
if (_frame == 708)
{
    keyboard_key_release(controls_key("pistol"));
    check(o_TrainingSimulation.stage == 1 && o_TrainingSimulation.prompt == "coin_shoot", "178.13 Equipping pistol advances to throw and shoot prompt");
    check(string_pos("CHAIN", o_TrainingSimulation.objective) == 0, "178.14 Active coin instruction does not reveal chains");

    coin_stage = 0; coin_phase_time = 0; coin_section = 7;
}
if (_frame == 730) screen_save("/tmp/issue178-coins.png");
if (_frame >= 710 && _frame < 890 && (o_TrainingSimulation.section == 7 || o_TrainingSimulation.section == 8))
{
    var _section = o_TrainingSimulation.section;
    if (coin_section != _section)
    {
        check(_section == 8, "178.13 New equip step still permits three actual coin hits");
        coin_stage = 0; coin_phase_time = 0; coin_section = _section;
        keyboard_key_release(controls_key("fire"));
    }
    coin_phase_time++;
    if (coin_stage == 0)
    {
        keyboard_key_press(controls_key("coin")); coin_stage = 1; coin_phase_time = 0;
    }
    else if (coin_stage == 1 && coin_phase_time >= 4)
    {
        keyboard_key_release(controls_key("coin"));
        var _coin = instance_find(o_Coin, 0);
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
            aim_at(_coin.x, _coin.y);
            if (coin_phase_time >= 8) keyboard_key_press(controls_key("fire"));
        }
        else
        {
            keyboard_key_release(controls_key("fire")); coin_stage = 0; coin_phase_time = 0;
        }
    }
}
if (_frame == 895)
{
    keyboard_key_release(controls_key("coin")); keyboard_key_release(controls_key("fire"));
    check(o_TrainingSimulation.section == 9, "178.13/14 Coin exercises remain completable by real shooting and ricochets");
    with (o_TrainingSimulation) instance_destroy();
    with (o_Player) { pHP = 150; instance_destroy(); }
    room_goto(LE_TUTORIAL_WIP);
}
if (_frame == 940)
{
    check(!training_active() && o_Player.owns_pistol && o_Player.owns_sword, "178 Normal gameplay retains default equipment");
    check(training_camera_y(1234) == 1234, "178 Materials camera restriction does not leak outside simulation");
    show_debug_message("[TEST] ISSUE 178 COMPLETE");
    game_end();
}
if (_frame > 980) game_end();
