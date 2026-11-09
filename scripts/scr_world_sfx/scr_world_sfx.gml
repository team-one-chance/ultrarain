/// Play a local mechanical cue at a gain consistent with the player's distance.
function world_sfx_play(_asset, _x, _y, _gain = 1, _pitch = 1, _range = 640)
{
    var _player = instance_find(o_Player, 0);
    if (!instance_exists(_player)) return -1;
    var _distance = point_distance(_x, _y, _player.x, _player.y);
    var _volume = clamp(1 - _distance / max(1, _range), 0, 1) * _gain;
    if (_volume <= 0) return -1;
    var _sound = audio_play_sound(_asset, 1, false, _volume);
    audio_sound_pitch(_sound, _pitch);
    return _sound;
}
