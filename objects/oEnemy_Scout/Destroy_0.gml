// Keep room changes and editor removals silent, preserving inherited death effects.
scout_stop_roll_sound();
scout_stop_charge_sound();
if (!training_active() && variable_instance_exists(id, "ehp") && ehp <= 0)
{
    world_sfx_play(sfxScoutDeath, x, y);
}
event_inherited();
