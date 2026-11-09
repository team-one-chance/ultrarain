var _player = instance_find(o_Player, 0);
if (!instance_exists(_player)) exit;
if (_player.pHP <= 0 || _player.grinder_dying) exit;
if (variable_global_exists("dev_freecam") && global.dev_freecam) exit;

var _inside = abs(_player.x - x) <= max(1, trigger_width * abs(image_xscale)) * 0.5
    && abs(_player.y - y) <= max(1, trigger_height * abs(image_yscale)) * 0.5;

// Activate on entry so standing in a trigger cannot overwrite another save.
if (_inside && !player_was_inside)
{
    // Keep entry pending until the controller restores room state and syringe charges.
    if (!instance_exists(o_TutorialCheckpoint)
        || o_TutorialCheckpoint.checkpoint_layers_pending
        || o_TutorialCheckpoint.checkpoint_syringes_pending) exit;
    var _spawn = checkpoint_find_spawn();
    if (!is_struct(_spawn)) exit;
    o_TutorialCheckpoint.respawn_x = _spawn.x;
    o_TutorialCheckpoint.respawn_y = _spawn.y;
    o_TutorialCheckpoint.save_checkpoint_layers();
    o_TutorialCheckpoint.save_checkpoint_syringes(_player);
}
player_was_inside = _inside;
