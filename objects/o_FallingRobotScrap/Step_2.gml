// Physics has advanced, so check the actual movement.
var _started_grinding = false;

if (scrap_state == 0 && scrap_emerged)
{
    var _gear = scrap_find_surface([o_GrinderLeft, o_GrinderRight]);

    if (!is_undefined(_gear))
    {
        scrap_start_grind(_gear);
        _started_grinding = true;
    }
}

if (!_started_grinding
&& ((scrap_state == 0 && scrap_emerged) || scrap_state == 2))
{
    var _lava = scrap_find_surface([oMoltenLava], 32);

    if (!is_undefined(_lava))
    {
        scrap_start_sink(_lava);
    }
}

// Apply after the grinder and lava have changed depth.
if (instance_exists(o_Player))
{
    depth = max(depth, o_Player.depth + 1);
    scrap_normal_depth = max(scrap_normal_depth, o_Player.depth + 1);
}