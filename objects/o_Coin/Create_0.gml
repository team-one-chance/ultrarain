split_threshold = 0.75;

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