// Recheck after the player's Step, independent of instance execution order.
// This removes the slash before drawing the sword's upward recovery.
if (slash_owner != noone) sync_sword_swing();
