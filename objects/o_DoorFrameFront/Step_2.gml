if (!instance_exists(door_owner))
{
    instance_destroy();
    exit;
}

x = door_owner.x;
y = door_owner.y;
var _front_depth = door_owner.depth - 1;
var _player = instance_find(o_Player, 0);
if (instance_exists(_player))
{
    // Larger depths draw first. Keep the far jamb behind the player's body.
    var _back_depth = max(door_owner.depth, _player.depth + 1);
    if (door_owner.depth != _back_depth) door_owner.depth = _back_depth;
    _front_depth = _player.depth - 1;
}
if (depth != _front_depth) depth = _front_depth;
