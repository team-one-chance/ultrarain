var _player = instance_find(o_Player, 0);
if (instance_exists(_player) && layer != layer_get_id("Hazards")) {
    depth = _player.depth + 2;
}
