var _player = instance_nearest(x, y, o_Player);

if (instance_exists(_player))
{
    if (!_player.medkit_owned
    && _player.pHP > 0
    && point_distance(x, y, _player.x, _player.y - 32) <= 32)
    {
        _player.medkit_owned = true;
        _player.syringe_count = _player.syringe_max;

        instance_destroy();
    }
}