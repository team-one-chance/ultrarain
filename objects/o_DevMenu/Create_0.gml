// DEVELOPMENT CONFIG: set enabled to false for a release build.
enabled = true;
menu_key = vk_f1;
collision_key = vk_f2;
row_height = 30;
panel_width = 490;

if (!variable_global_exists("dev_invincible")) global.dev_invincible = false;
if (!variable_global_exists("dev_collisions")) global.dev_collisions = false;
global.dev_resume_input = false;
if (!enabled)
{
    global.dev_invincible = false;
    global.dev_collisions = false;
}
opened = false;
selected = 0;
row_count = 11;
paused_surface = -1;
paused_instances = [];
test_position = undefined;
spawn_position = undefined;
cursor_position = [0, 0];

resume_game = function()
{
    if (!opened) return;
    for (var i = 0; i < array_length(paused_instances); ++i)
        instance_activate_object(paused_instances[i]);
    paused_instances = [];
    physics_pause_enable(false);
    opened = false;
    global.dev_resume_input = true;
    keyboard_clear(vk_enter);
    mouse_clear(mb_left);
    if (surface_exists(paused_surface)) surface_free(paused_surface);
    paused_surface = -1;
};

teleport_player = function(_position)
{
    if (is_undefined(_position) || !instance_exists(o_Player)) return;
    with (o_Player)
    {
        phy_position_x = _position[0];
        phy_position_y = _position[1];
        phy_speed_x = 0;
        phy_speed_y = 0;
        damage_knockback_timer = 0;
        damage_knockback_pending = false;
        is_slamming = false;
        slam_last_y = _position[1];
    }
};

run_action = function(_row)
{
    // Toggles stay open. Actions resume gameplay before accessing the player.
    if (_row == 0) { global.dev_collisions = !global.dev_collisions; return; }
    if (_row == 1) { global.dev_invincible = !global.dev_invincible; return; }
    if (_row == 7 && is_undefined(test_position)) return;
    resume_game();
    switch (_row)
    {
        case 2:
            with (o_Player) { pHP = pHP_max; coin_count = coin_max; }
            break;
        case 3:
        case 4:
            with (o_Player)
            {
                weapon_type = (_row == 3) ? "pistol" : "sword";
                aim_rig_mode = (_row == 3) ? AimRigMode.ONE_HANDED : AimRigMode.TWO_HANDED;
                sword_swing_timer = 0;
                sword_swing_pending_hit = false;
                weapon_fire_timer = 0;
            }
            break;
        case 5: teleport_player(cursor_position); break;
        case 6:
            if (instance_exists(o_Player)) test_position = [o_Player.x, o_Player.y];
            break;
        case 7: teleport_player(test_position); break;
        case 8: teleport_player(spawn_position); break;
        case 9: room_restart(); break;
    }
};
