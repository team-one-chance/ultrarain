o_Player.pHP += 25;
show_debug_message("APPLE TOUCHED PLAYER!");

if (o_Player.pHP > o_Player.pHP_max)
{
    o_Player.pHP = o_Player.pHP_max;
}

instance_destroy();
