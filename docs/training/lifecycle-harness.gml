global.training_check_frame++;
var _frame = global.training_check_frame;
if (_frame == 1)
{
    check(instance_exists(o_BootMenu), "Menu exists");
    check(o_BootMenu.boot_menu_options()[0] == "TRAINING SIMULATION", "Training is above Start");
    o_BootMenu.menu_selection = 0;
    o_BootMenu.boot_menu_activate();
}
if (_frame == 30)
{
    check(training_active(), "Menu launches training");
    check(!instance_exists(o_BootMenu), "Persistent menu removed");
    check(o_Player.weapon_type == "none" && !o_Player.owns_pistol && !o_Player.owns_sword, "Starts unarmed");
    check(o_Player.pHP == 150 && o_Player.pHP_max == 150, "Fixed HP");
    check(!training_action_allowed("left") && !training_action_allowed("coin"), "Initial action locks");
    check(array_length(o_TrainingSimulation.notes) == 51, "All notes recovered");
}
if (_frame == 60)
{
    check(o_TrainingSimulation.section == 0, "Waiting does not complete aim exercise");
    if (surface_exists(application_surface)) screen_save( "/tmp/training-look.png");
}
// Actual aiming uses the live crosshair, with camera-to-window conversion.
if (_frame >= 65 && _frame <= 135 && _frame mod 10 == 5)
{
    var _index = (_frame - 65) div 10;
    var _actor = o_TrainingSimulation.targets[_index].actor;
    if (instance_exists(_actor))
    {
        var _cam = view_camera[0];
        var _scale = min(window_get_width() / surface_get_width(application_surface), window_get_height() / surface_get_height(application_surface));
        var _offset_x = (window_get_width() - surface_get_width(application_surface) * _scale) / 2;
        var _offset_y = (window_get_height() - surface_get_height(application_surface) * _scale) / 2;
        window_mouse_set(_offset_x + (_actor.x + 12 - camera_get_view_x(_cam)) / camera_get_view_width(_cam) * surface_get_width(application_surface) * _scale,
            _offset_y + (_actor.y + 12 - camera_get_view_y(_cam)) / camera_get_view_height(_cam) * surface_get_height(application_surface) * _scale);
    }
}
if (_frame >= 66 && _frame <= 136 && _frame mod 10 == 6)
    show_debug_message("[TEST] cursor " + string(mouse_x) + "," + string(mouse_y));
if (_frame == 150)
{
    check(o_TrainingSimulation.section == 1, "Actual aiming completes all eight nodes");
    o_TrainingSimulation.enter(2);
}
if (_frame == 180)
{
    check(o_TrainingSimulation.section == 2, "Slide section initializes");
    check(!o_Player.owns_pistol && training_action_allowed("dash") && !training_action_allowed("slam"), "Movement-only unlocks");
    o_TrainingSimulation.enter(3);
}
if (_frame == 210)
{
    check(array_length(o_TrainingSimulation.floor_blocks) == 5 && instance_number(o_Block_Breakable) == 5, "Five slam floor segments");
    o_TrainingSimulation.reset_pending = true;
}
if (_frame == 240)
{
    check(o_TrainingSimulation.section == 3 && instance_number(o_Block_Breakable) == 5, "Retry restores floor without duplicates");
    o_TrainingSimulation.enter(4);
}
if (_frame == 270)
{
    check(o_Player.owns_pistol && !o_Player.owns_sword && o_Player.weapon_type == "pistol", "Pistol-only unlock");
    check(array_length(o_TrainingSimulation.targets) == 4, "Four pistol targets");
    with (o_TrainingTarget) take_damage(100);
}
if (_frame == 300)
{
    check(o_TrainingSimulation.section == 5 && o_TrainingSimulation.stage == 0, "Pistol kills advance; sword wave waits for switch");
    o_Player.weapon_type = "sword";
}
if (_frame == 330)
{
    check(instance_number(o_TrainingTarget) == 1, "Sword switch spawns first wave once");
    with (o_TrainingTarget) take_damage(100, 0, 0, true);
}
if (_frame == 360)
{
    check(instance_number(o_TrainingTarget) == 2, "First sword kill spawns two targets");
    with (o_TrainingTarget) take_damage(100, 0, 0, true);
}
if (_frame == 390)
{
    check(o_TrainingSimulation.section == 6, "Sword wave advances to materials");
    with (o_TrainingTarget) take_damage(100);
}
if (_frame == 420)
{
    var _target = instance_find(o_TrainingTarget, 0);
    check(_target.training_kind == 2 && _target.shield_hp == 100, "Armored material spawns second");
    _target.take_damage(10);
    check(_target.shield_hp == 99 && _target.ehp == 30, "Pistol chips shield using x0.1");
    _target.take_damage(10, 0, 0, true);
    check(_target.shield_hp == 49 && _target.ehp == 30, "Sword strips shield using x5");
    _target.take_damage(100, 0, 0, true);
    _target.take_damage(100, 0, 0, true);
}
if (_frame == 450)
{
    check(instance_number(o_TrainingTarget) == 2, "Floating plate and unarmored body are separate");
    if (surface_exists(application_surface)) screen_save( "/tmp/training-shield.png");
    with (o_TrainingTarget) if (training_kind == 3) take_damage(100, 0, 0, true);
}
if (_frame == 480)
{
    check(o_TrainingSimulation.section == 7, "Materials advance to coins");
    check(o_Player.coin_count == 4 && o_TrainingSimulation.prompt == "pistol", "Coin equip step initializes");
    o_Player.pHP = 0;
}
if (_frame == 510)
{
    check(o_TrainingSimulation.section == 7 && o_Player.pHP == 150 && !instance_exists(oGameOver), "Lethal damage resets only current section");
    check(o_Player.owns_sword && o_Player.owns_pistol && o_TrainingSimulation.coin_hits == 0, "Retry preserves correct equipment and resets objective");
    o_Player.owns_pistol = false;
    o_Player.weapon_type = "pistol";
    o_Player.weapon_validate();
    check(o_Player.weapon_type == "sword", "Sword-only selection is valid");
    o_Player.owns_sword = false;
    o_Player.weapon_validate();
    check(o_Player.weapon_type == "none", "Removing all weapons clears selection");
    o_TrainingSimulation.enter(8);
}
if (_frame == 540)
{
    check(!training_action_allowed("left") && training_action_allowed("fire"), "Ricochet exercise locks movement but permits shooting");
    with (o_TrainingTarget) take_damage(100);
}
if (_frame == 570)
{
    check(o_TrainingSimulation.section == 9 && instance_number(oEnemy_Scout) == 0, "Combat starts with one-second spawn delay");
}
if (_frame == 630)
{
    check(instance_number(oEnemy_Scout) == 1, "Scout appears exactly once");
    if (surface_exists(application_surface)) screen_save( "/tmp/training-combat.png");
    with (oEnemy_Scout) take_damage(1000);
}
if (_frame == 660)
{
    check(instance_number(oDrone) == 1, "Scout kill spawns drone");
    with (oDrone) take_damage(1000);
}
if (_frame == 690)
{
    check(o_TrainingSimulation.terminal_ready, "Drone kill exposes terminal");
    check(instance_number(oEnemy_Breaker) == 0, "No unrelated boss spawned");
    var _terminal = o_TrainingSimulation.note("terminal lucidity");
    o_Player.phy_position_x = _terminal.x;
    o_Player.phy_position_y = _terminal.y + 64;
    keyboard_key_press(controls_key("interact"));
}
if (_frame == 692) keyboard_key_release(controls_key("interact"));
if (_frame == 720)
{
    check(o_TrainingSimulation.ending_time >= 0, "Terminal interaction starts error sequence");
    screen_save("/tmp/training-terminal.png");
}
if (_frame == 830)
{
    check(room == LE_MENU && instance_exists(o_BootMenu), "Terminal error sequence returns to main menu");
    check(!global.demo_took_damage && !global.demo_used_healing && is_undefined(global.demo_travel_state), "Completion clears gameplay run state");
    o_BootMenu.menu_selection = 0;
    o_BootMenu.boot_menu_activate();
}
if (_frame == 860)
{
    check(o_TrainingSimulation.section == 0 && array_length(o_TrainingSimulation.targets) == 8, "Simulation can be replayed cleanly");
    with (o_TrainingSimulation) instance_destroy();
    with (o_Player) { pHP = 150; instance_destroy(); }
    room_goto(LE_TUTORIAL_WIP);
}
if (_frame == 920)
{
    check(instance_exists(o_Player) && o_Player.owns_pistol && o_Player.owns_sword, "Normal game starts with default equipment");
    check(!training_active() && training_action_allowed("slam") && training_action_allowed("coin"), "Training restrictions do not leak");
    show_debug_message("[TEST] COMPLETE");
    game_end();
}
if (_frame > 950) game_end();
