var _player = instance_place(x, y, o_Player);

if (instance_exists(_player))
{
    if (_player.pHP > 0
    && _player.syringe_count < _player.syringe_max)
    {
        _player.medkit_owned = true;
        _player.syringe_count = _player.syringe_max;

        audio_play_sound(sfxMedkitPickup, 1, false);
        instance_destroy();
    }
}
