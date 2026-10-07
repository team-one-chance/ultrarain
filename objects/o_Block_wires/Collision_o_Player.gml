// Dash and slam protection also block this hazard.
if (other.damage_blocks_damage()) exit;

// Mark this instant-kill hazard as a death before the Destroy event runs.
other.pHP = 0;
global.demo_took_damage = true;
instance_destroy(other);
