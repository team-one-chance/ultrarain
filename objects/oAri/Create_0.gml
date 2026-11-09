ari_state = "waiting"; // Scene order: closing bars, arriving, prompt/dialogue, departing, opening bars.
ari_elapsed = 0; // Seconds spent in the current scene state.
ari_bars = 0; // Normalized cinematic bar closure: 0 = open, 1 = fully closed.
ari_text_chars = 0; // Revealed characters in the current dialogue line; fractional progress keeps typing smooth.
ari_voice_config = {
    sound: sfxAriTalk,
    gain: 0.55, // Linear gain; keep the voice below combat effects.
    pitch: 1.0, // Playback ratio; Samuel overrides this shared dialogue configuration.
    pitch_range: 0.10, // Maximum pitch deviation per syllable; larger values sound more animated.
    interval: 0.075 // Seconds between syllables; rate limiting prevents overlapping chatter on slow frames.
};
ari_voice_handle = -1;
ari_voice_cooldown = 0; // Seconds until another syllable can play.
ari_stop_voice = function()
{
    if (ari_voice_handle != -1) audio_stop_sound(ari_voice_handle);
    ari_voice_handle = -1;
    ari_voice_cooldown = 0;
};
ari_scene_config = {
    bar_seconds: 0.55, // Seconds to close or reopen the cinematic bars.
    bar_fraction: 0.12, // Fraction of screen width covered by each fully closed side bar.
    dialogue_width: 620, // GUI pixels at 1280x720; smaller values narrow the dialogue panel.
    dialogue_text_scale: 0.7, // Font-size multiplier; keeps the conversation compact below the characters.
    arrive_seconds: 0.75, // Seconds for Ari's Matrix-style reconstruction.
    depart_seconds: 0.65, // Seconds for Ari's digital disintegration after dropping the gift.
    text_chars_per_second: 38, // Characters per second; larger values type faster.
    drop_right_pixels: 52, // Pixels beyond Ari's right edge; keeps the gift away from the held player.
    drop_right_speed: 1.2, // Physics movement units; positive tosses the gift right, toward the door.
    drop_up_speed: -1.5 // Physics movement units; negative creates a small upward arc.
};
ari_player = noone;
ari_display_name = "Ari"; // Speaker label shared by the cinematic and overhead name.
ari_can_start = function(_player) { return true; }; // Character-specific entrance condition, evaluated before locking controls.
ari_scene_finished = function() {}; // Character-specific action after the bars reopen and controls return.
ari_visit = "intro"; // intro awards Pinhouse; assist is the one-time third-death medkit conversation.
ari_drop_x = 0; // Validated medkit landing position in room pixels.
ari_drop_y = 0;
ari_enemy_freeze_owned = false; // Restore the previous development enemy-freeze setting when this scene ends.
ari_previous_enemy_freeze = false;
ari_trigger_x = 1264; // Room pixels; walking past this point starts the encounter before the first door.
ari_floor_y = 192; // Room pixels at the opening corridor floor; aligns both characters' feet.
ari_hold_x = ari_trigger_x;
ari_hold_y = ari_floor_y - 1;
ari_dialogue_index = 0; // Zero-based index of the line currently shown.
ari_dialogue = [
    "Looks like you've gone rogue.",
    "Frankly speaking I'm also tired of the way things have been around here.",
    "Maybe you can escape and bring about a change.",
    "Here, take this, maybe it'll help you on your journey.",
    "Good luck."
];

ari_set_state = function(_state)
{
    ari_stop_voice();
    ari_state = _state;
    ari_elapsed = 0;
};

ari_hold_player = function()
{
    if (!instance_exists(ari_player)) return;
    ari_player.phy_position_x = ari_hold_x;
    ari_player.phy_position_y = ari_hold_y;
    ari_player.phy_speed_x = 0;
    ari_player.phy_speed_y = 0;
    var _ari_centre_x = (bbox_left + bbox_right) * 0.5;
    var _facing = sign(_ari_centre_x - ari_hold_x);
    if (_facing == 0) _facing = 1;
    ari_player.image_xscale = _facing;
    ari_player.aim_facing = _facing;
    ari_player.aim_angle = point_direction(ari_hold_x, ari_hold_y - 40,
        _ari_centre_x, (bbox_top + bbox_bottom) * 0.5); // Degrees; face the head and weapon toward Ari instead of the cursor.
};

ari_release_player = function()
{
    ari_stop_voice();
    if (ari_enemy_freeze_owned)
    {
        global.dev_freeze_enemies = ari_previous_enemy_freeze;
        ari_enemy_freeze_owned = false;
    }
    if (instance_exists(ari_player) && ari_player.ari_interaction_owner == id)
    {
        ari_player.ari_interaction_owner = noone;
        ari_player.footstep_last_x = ari_player.x;
    }
};

// Check the walking route, Ari's full height, continuous floor, and nearby hazards before placing a gift.
ari_checkpoint_layout = function(_checkpoint_x, _checkpoint_y)
{
    var _hazards = [o_Block_scary, o_Block_wires, o_Block_wires_left, o_Block_wires_right,
        o_GrinderLeft, o_GrinderRight, oTrap, oMoltenLava, oLavaMolten, oLavaFromTheMolten];
    var _floor = -1;
    for (var _down = 0; _down <= 96; ++_down)
    {
        if (collision_point(_checkpoint_x, _checkpoint_y + _down, o_Block, false, true) != noone)
        {
            _floor = _checkpoint_y + _down;
            break;
        }
    }
    if (_floor < 0) return undefined;
    var _shifts = [0, -32, 32, -64, 64, -96, 96, -128, 128]; // Room pixels; prefer the exact checkpoint, then its immediate safe surroundings.
    for (var _i = 0; _i < array_length(_shifts); ++_i)
    {
        var _player_x = _checkpoint_x + _shifts[_i];
        for (var _side = -1; _side <= 1; _side += 2)
        {
            var _ari_x = _player_x + 64 * _side; // Pixels between body centres; Ari stands between the player and gift.
            var _gift_x = _player_x + 104 * _side; // Pixels from player to landing; beyond Ari, never thrown toward the player.
            var _left = min(_checkpoint_x, _player_x, _gift_x) - 20; // Pixels of lateral clearance; covers the 27-pixel standing collider and 32-pixel gift.
            var _right = max(_checkpoint_x, _player_x, _gift_x) + 20;
            if (_left < 0 || _right >= room_width) continue;
            if (collision_rectangle(_left, _floor - 96, _right, _floor - 2, o_Block, false, true) != noone) continue;
            if (collision_rectangle(_ari_x - 22, _floor - 96, _ari_x + 22, _floor - 2, o_Block, false, true) != noone) continue;
            if (collision_rectangle(_left, _floor - 72, _right, _floor - 2, o_Door_UNB, false, true) != noone) continue;
            var _safe = true;
            for (var _h = 0; _h < array_length(_hazards); ++_h)
            {
                if (collision_rectangle(_left - 16, _floor - 112, _right + 16, _floor + 8, _hazards[_h], false, true) != noone)
                {
                    _safe = false;
                    break;
                }
            }
            // Test the entire walkable route, not only the item's landing point; reject ledges and pits.
            for (var _sample = _left; _sample <= _right; _sample += 8)
            {
                if (collision_point(_sample, _floor, o_Block, false, true) == noone) { _safe = false; break; }
            }
            if (_safe) return { player_x: _player_x, ari_x: _ari_x, gift_x: _gift_x, floor_y: _floor, side: _side };
        }
    }
    return undefined;
};

ari_drop_medkit = function(_animate = true)
{
    var _centre_x = (bbox_left + bbox_right) * 0.5;
    instance_create_depth(_animate ? _centre_x : ari_drop_x, _animate ? ari_floor_y - 48 : ari_drop_y,
        depth - 1, o_MedkitPickup,
        { ari_assist_gift: true, ari_drop_elapsed: _animate ? 0 : 0.55,
          ari_drop_duration: 0.55, // Seconds for the controlled toss; its validated arc cannot drift into a hazard.
          ari_drop_start_x: _centre_x, ari_drop_start_y: ari_floor_y - 48,
          ari_drop_target_x: ari_drop_x, ari_drop_target_y: ari_drop_y });
    global.tutorial_ari_assist = 1; // Preserve an uncollected gift through another death without replaying the dialogue.
};

ari_prepare_checkpoint_visit = function(_checkpoint_x, _checkpoint_y)
{
    var _layout = ari_checkpoint_layout(_checkpoint_x, _checkpoint_y);
    if (!is_struct(_layout)) return false; // Wait for a safe layout instead of dropping onto a trap or into the player.
    ari_visit = "assist";
    ari_hold_x = _layout.player_x;
    ari_floor_y = _layout.floor_y;
    ari_hold_y = ari_floor_y - 1;
    ari_drop_x = _layout.gift_x;
    ari_drop_y = ari_floor_y - 1;
    image_xscale = -_layout.side;
    x = _layout.ari_x - (sprite_get_bbox_left(sprite_index) + sprite_get_bbox_right(sprite_index)) * 0.5 * image_xscale;
    y = ari_floor_y - sprite_get_bbox_bottom(sprite_index) - 1;
    ari_dialogue = [
        "Strugglin' quite a bit aren't you?",
        "No one said it was gonna be easy.",
        "Here, take this Znuni, it should help you survive.",
        "well then, until next time."
    ];
    if (global.tutorial_ari_assist == 1)
    {
        ari_drop_medkit(false);
        instance_destroy();
    }
    return true;
};

// Keep Ari as an ordinary ambient character outside this tutorial.
if (room != LE_TUTORIAL_WIP)
{
    ari_state = "ambient";
    exit;
}
visible = false;
y = ari_floor_y - sprite_get_bbox_bottom(sprite_index) - 1;
image_xscale = -1; // Face left toward the approaching player; the sprite origin is its top-left corner.
