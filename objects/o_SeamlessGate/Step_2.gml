// END STEP: movement and normal camera Step have finished before the snapshot.
var _player = instance_find(o_Player, 0);
if (!instance_exists(_player) || _player.pHP <= 0) exit;
var _progress = (_player.x - x) * cross_direction;
if (previous_player != _player)
{
    previous_player = _player;
    previous_progress = _progress;
    exit;
}
var _crossed = previous_progress < 0 && _progress >= 0;
previous_progress = _progress;
if (!is_exit || !_crossed || abs(_player.y - y) > vertical_tolerance) exit;
if (variable_global_exists("dev_freeze_enemies") && global.dev_freeze_enemies
&& variable_global_exists("dev_delta_time") && global.dev_delta_time <= 0) exit;

var _manager = instance_find(o_SeamlessTravel, 0);
if (!instance_exists(_manager))
{
    show_debug_message("Seamless entrance: place o_SeamlessTravel in the source room.");
    exit;
}
if (!is_undefined(_manager.pending) || _manager.transition_cooldown > 0) exit;
var _destination = asset_get_index(destination_room_name);
if (_destination == -1 || !room_exists(_destination))
{
    show_debug_message("Seamless entrance: create room " + destination_room_name + ".");
    exit;
}
_manager.pending = seamless_capture(_player, id, _destination);
room_goto(_destination);
exit;
