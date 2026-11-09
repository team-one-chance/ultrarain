if (variable_instance_exists(id, "ari_assist_gift") && ari_assist_gift && ari_drop_elapsed < ari_drop_duration)
{
    ari_drop_elapsed = min(ari_drop_duration, ari_drop_elapsed
        + max(0, (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) / 1000000));
    var _progress = ari_drop_elapsed / ari_drop_duration;
    x = lerp(ari_drop_start_x, ari_drop_target_x, _progress);
    y = lerp(ari_drop_start_y, ari_drop_target_y, _progress) - sin(pi * _progress) * 16; // Room pixels; shallow arc stays inside the checked clearance.
    exit; // Do not collect in flight; the gift must land at its safe position first.
}
var _player = instance_place(x, y, o_Player);

if (instance_exists(_player))
{
    if (_player.pHP > 0
    && _player.syringe_count < _player.syringe_max)
    {
        _player.medkit_owned = true;
        _player.syringe_count = _player.syringe_max;
        // Run inventory remembers the first pickup across rooms and checkpoint retries.
        if (item_add_level(_player, "medkit"))
        {
            _player.item_notice_key = "medkit";
            _player.item_notice_time = 5; // Seconds of fallback instructions when no pause controller exists.
            if (instance_exists(o_PauseMenu))
            {
                o_PauseMenu.pickup_notice_pending = "medkit"; // Open the same paused panel as Pinhouse on the next Begin Step.
                _player.item_notice_time = 0;
            }
        }
        if (variable_instance_exists(id, "ari_assist_gift") && ari_assist_gift)
            global.tutorial_ari_assist = 2; // This one-time gift and medkit ownership survive subsequent checkpoint deaths.

        audio_play_sound(sfxMedkitPickup, 1, false);
        instance_destroy();
    }
}
