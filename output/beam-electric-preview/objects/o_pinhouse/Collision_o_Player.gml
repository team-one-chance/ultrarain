if (item_collected) exit;

if (!item_controller_collect(id, other)) exit;

other.item_coin_anchor = true;
other.coin_anchor_cooldown_timer = 0;

audio_play_sound(sfxPinhousePickup, 1, false);