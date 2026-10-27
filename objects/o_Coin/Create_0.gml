var _player = instance_find(o_Player, 0);
depth = instance_exists(_player) ? _player.depth - 1 : -1;
is_pinned = false;
pin_owner = noone;
geometry_stall_time = 0;
split_threshold = 0.75;

// Play once whenever a coin is thrown.
audio_play_sound(sfxCoin, 1, false);
// Draw in front of every molten-lava instance.
for (var _i = 0; _i < instance_number(oMoltenLava); _i++)
{
    var _lava = instance_find(oMoltenLava, _i);
    depth = min(depth, _lava.depth - 1);
}

// =====================================
// APEX ANIMATION
// =====================================

apex_anim_frame = 0;
apex_anim_speed = 27; // frames per second
