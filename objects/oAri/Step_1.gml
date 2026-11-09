if (ari_state == "ambient") exit;
if (variable_global_exists("dev_freecam") && global.dev_freecam) exit;
if (variable_global_exists("dev_resume_input") && global.dev_resume_input) exit;
var _dt = max(0, (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) / 1000000);

if (ari_state == "waiting")
{
    var _player = instance_find(o_Player, 0);
    if (!instance_exists(_player) || _player.pHP <= 0 || _player.grinder_dying) exit;
    if (instance_exists(_player.ari_interaction_owner) || !ari_can_start(_player)) exit;
    // The checkpoint controller restores doors/layers before choosing a safe assistance layout.
    if (instance_exists(o_TutorialCheckpoint) && o_TutorialCheckpoint.ari_retry_visit_pending) exit;
    // An owned reward survives room travel and must not produce another encounter.
    if (ari_visit == "intro" && item_get_level(_player, "coin_anchor") > 0)
    {
        instance_destroy();
        exit;
    }
    if (ari_visit == "intro"
        && (_player.x < ari_trigger_x || _player.x > 1600 || _player.y > ari_floor_y + 32)) exit;
    if (_player.hacking_controller != noone) exit;

    ari_player = _player;
    if (ari_visit != "intro")
    {
        ari_previous_enemy_freeze = variable_global_exists("dev_freeze_enemies") && global.dev_freeze_enemies;
        global.dev_freeze_enemies = true; // Keep the checkpoint conversation safe from approaching enemies.
        ari_enemy_freeze_owned = true;
    }
    // Cancel movement actions so a dash, jump, or slide cannot skip the conversation.
    ari_player.stop_movement_sfx();
    ari_player.is_sliding = false;
    ari_player.slide_direction = 0;
    ari_player.slide_exit_timer = 0;
    ari_player.slide_boost_timer = 0;
    ari_player.slide_double_boost_stage = 0;
    ari_player.dash_active = false;
    ari_player.dash_current_speed = 0;
    ari_player.dash_burst_timer = 0;
    ari_player.dash_iframe_timer = 0;
    ari_player.is_slamming = false;
    ari_player.is_ledge_climbing = false;
    ari_player.is_mantle_lunging = false;
    ari_player.sword_swing_timer = 0;
    ari_player.sword_swing_pending_hit = false;
    ari_player.parry_timer = 0;
    ari_player.parry_visual_time = -1;
    ari_player.player_set_collider(false);
    ari_player.sprite_index = s_Player;
    ari_player.image_index = 0;
    ari_player.image_speed = 0;
    ari_player.footstep_timer = 0;
    ari_hold_player();
    ari_player.ari_interaction_owner = id; // Lock controls after the body, head, and aim face Ari.
    ari_set_state("closing");
    visible = true;
    exit;
}

if (!instance_exists(ari_player) || ari_player.pHP <= 0 || ari_player.grinder_dying)
{
    ari_release_player();
    instance_destroy();
    exit;
}
ari_hold_player();
ari_elapsed += _dt;
if (ari_state == "closing" || ari_state == "opening")
{
    var _progress = clamp(ari_elapsed / ari_scene_config.bar_seconds, 0, 1);
    var _ease = _progress * _progress * (3 - 2 * _progress);
    ari_bars = ari_state == "closing" ? _ease : 1 - _ease;
    if (_progress >= 1)
    {
        if (ari_state == "closing") ari_set_state("arriving");
        else
        {
            ari_release_player();
            ari_scene_finished();
            instance_destroy();
        }
    }
    exit;
}
if (ari_state == "arriving" || ari_state == "departing")
{
    var _duration = ari_state == "arriving" ? ari_scene_config.arrive_seconds : ari_scene_config.depart_seconds;
    if (ari_elapsed >= _duration)
    {
        var _next_state = ari_state == "arriving" ? "prompt" : "opening";
        if (ari_state == "arriving" && ari_visit == "samuel")
        {
            _next_state = "dialogue"; // Samuel speaks immediately after appearing; Ari still waits for interaction.
            ari_text_chars = 0;
        }
        ari_set_state(_next_state);
    }
    exit;
}
if (ari_state == "dialogue")
{
    var _old_chars = floor(ari_text_chars);
    var _line = ari_dialogue[ari_dialogue_index];
    ari_text_chars = min(string_length(_line),
        ari_text_chars + ari_scene_config.text_chars_per_second * _dt);
    ari_voice_cooldown = max(0, ari_voice_cooldown - _dt);
    // Read only newly typed characters: revealing a whole line never queues a burst of sounds.
    var _voiced = false;
    for (var _letter = _old_chars + 1; _letter <= floor(ari_text_chars); ++_letter)
    {
        var _char = string_char_at(_line, _letter);
        if (string_pos(_char, ".,!?;:") > 0)
        {
            ari_voice_cooldown = max(ari_voice_cooldown, string_pos(_char, ".!?") > 0 ? 0.18 : 0.10);
        }
        else if (!_voiced && ari_voice_cooldown <= 0
            && string_pos(string_lower(_char), "abcdefghijklmnopqrstuvwxyz0123456789") > 0)
        {
            if (ari_voice_handle != -1) audio_sound_gain(ari_voice_handle, 0, 8);
            // Letter-based variation avoids consuming gameplay's random-number sequence.
            var _variation = sin(ord(_char) * 1.73 + _letter * 0.91 + ari_dialogue_index * 2.3);
            var _pitch = ari_voice_config.pitch + _variation * ari_voice_config.pitch_range;
            ari_voice_handle = audio_play_sound(ari_voice_config.sound, 2, false,
                ari_voice_config.gain, 0, _pitch);
            ari_voice_cooldown = ari_voice_config.interval;
            _voiced = true;
        }
    }
}
if (!controls_pressed("interact")) exit;

// Consume the press so it cannot also activate the door controller or another interaction.
var _key = controls_key("interact");
if (_key < 0) mouse_clear(-_key); else keyboard_clear(_key);
if (ari_state == "prompt")
{
    ari_set_state("dialogue");
    ari_text_chars = 0;
    exit;
}
if (ari_text_chars < string_length(ari_dialogue[ari_dialogue_index]))
{
    ari_stop_voice();
    ari_text_chars = string_length(ari_dialogue[ari_dialogue_index]); // One press finishes typing; the next advances.
    exit;
}
if (ari_dialogue_index < array_length(ari_dialogue) - 1)
{
    ari_stop_voice();
    ari_dialogue_index++;
    ari_text_chars = 0;
    exit;
}

// Toss the gift beyond Ari's right edge so the player must walk over and collect it.
if (ari_visit == "assist")
{
    ari_drop_medkit();
}
else if (ari_visit == "intro" && item_get_level(ari_player, "coin_anchor") == 0)
{
    var _drop_x = bbox_right + ari_scene_config.drop_right_pixels;
    var _pickup = instance_create_depth(_drop_x, ari_floor_y - 48, depth - 1, o_pinhouse);
    if (instance_exists(_pickup))
    {
        _pickup.phy_speed_x = ari_scene_config.drop_right_speed;
        _pickup.phy_speed_y = ari_scene_config.drop_up_speed;
    }
}
ari_set_state("departing"); // Keep control locked through Ari's exit and the bars reopening.
