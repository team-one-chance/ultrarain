player_was_inside = false;
checkpoint_find_spawn = function()
{
    var _offsets = [0, 16, -16, 32, -32]; // Room pixels; prefer the marker, then nearby supported positions at platform edges.
    var _hazards = [o_Block_scary, o_Block_wires, o_Block_wires_left, o_Block_wires_right,
        o_GrinderLeft, o_GrinderRight, oTrap, oMoltenLava, oLavaMolten, oLavaFromTheMolten];
    for (var _i = 0; _i < array_length(_offsets); ++_i)
    {
        var _spawn_x = x + _offsets[_i];
        for (var _down = 0; _down <= 128; ++_down) // Pixels below the marker; covers checkpoints placed above a platform.
        {
            var _floor_y = y + _down;
            if (collision_point(_spawn_x, _floor_y, o_Block, false, true) == noone) continue;
            if (collision_point(_spawn_x - 12, _floor_y, o_Block, false, true) == noone
                || collision_point(_spawn_x + 13, _floor_y, o_Block, false, true) == noone) break;
            // Match the player's standing fixture: 27 pixels wide and 59 pixels tall.
            if (collision_rectangle(_spawn_x - 13, _floor_y - 60,
                _spawn_x + 14, _floor_y - 2, o_Block, false, true) != noone) break;
            var _safe = true;
            for (var _h = 0; _h < array_length(_hazards); ++_h)
            {
                if (collision_rectangle(_spawn_x - 14, _floor_y - 60,
                    _spawn_x + 15, _floor_y + 2, _hazards[_h], false, true) != noone)
                {
                    _safe = false;
                    break;
                }
            }
            if (_safe) return { x: _spawn_x, y: _floor_y - 1 };
            break;
        }
    }
    return undefined;
};
