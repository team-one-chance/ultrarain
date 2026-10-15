// Give item to player.
other.item_coin_anchor = true;

// Item is immediately usable.
other.coin_anchor_cooldown_timer = 0;

audio_play_sound(sfxPinhousePickup, 1, false);

// Remove pickup from room.
instance_destroy();
