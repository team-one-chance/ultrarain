// Reapply after physics so gravity and residual forces cannot move the held player.
if (ari_state != "waiting" && ari_state != "ambient") ari_hold_player();
