if (place_meeting(x, y, o_Player))
{
    o_Player.pHP += 25;

    if (o_Player.pHP > o_Player.pHP_max)
    {
        o_Player.pHP = o_Player.pHP_max;
    }

    instance_destroy();
}