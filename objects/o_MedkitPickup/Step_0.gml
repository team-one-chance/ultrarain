var _player = instance_nearest(x, y, o_Player);

if (instance_exists(_player))
{
    if (_player.pHP > 0
    && _player.syringe_count < _player.syringe_max
    && point_distance(
        x, y,
        _player.x, _player.y - 32
    ) <= 32)
    {
        _player.medkit_owned = true;
        _player.syringe_count = _player.syringe_max;

        audio_play_sound(sfxMedkitPickup, 1, false);
        instance_destroy();
    }
}
