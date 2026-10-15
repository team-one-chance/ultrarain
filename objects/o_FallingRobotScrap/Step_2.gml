// Physics has advanced by End Step, so surface checks sweep that actual motion.
if (scrap_state == 0 && scrap_emerged)
{
    var _gear = scrap_find_surface([o_GrinderLeft, o_GrinderRight]);
    if (!is_undefined(_gear))
    {
        scrap_start_grind(_gear);
        exit;
    }
}

if ((scrap_state == 0 && scrap_emerged) || scrap_state == 2)
{
    var _lava = scrap_find_surface([oMoltenLava], 32);
    if (!is_undefined(_lava)) scrap_start_sink(_lava);
}
