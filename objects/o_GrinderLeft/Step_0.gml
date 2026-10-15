image_index = floor(global.grinder_animation_time * 24) mod 72;

var _player = instance_place(x, y, o_Player);

if (_player != noone)
{
    _player.begin_grinder_death(id);
}