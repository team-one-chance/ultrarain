scout_stop_roll_sound();
scout_stop_charge_sound();
if (variable_instance_exists(id, "ehp") && ehp <= 0)
{
    world_sfx_play(sfxScoutDeath, x, y, 1, scout_sfx_pitch);
}
event_inherited();
