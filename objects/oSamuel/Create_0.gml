// Inherit Ari's bars, control lock, glitch rendering, name label, and typewriter interaction.
event_inherited();
if (room != LE_PWR)
{
    instance_destroy();
    exit;
}
ari_state = "waiting"; // Override Ari's ambient-room default; Samuel's cinematic belongs to LE_PWR.
visible = false;
ari_display_name = "Samuel";
ari_voice_config = {
    sound: sfxSamTalk,
    gain: 0.50, // Linear gain; the heavier voice stays below combat effects.
    pitch: 0.90, // Playback ratio; makes Samuel lower than Ari.
    pitch_range: 0.07, // Smaller pitch movement gives Samuel a more restrained delivery.
    interval: 0.095 // Seconds between syllables; slower than Ari's lighter chatter.
};
ari_visit = "samuel";
samuel_encounter_finished = false; // Gate the existing ambush until the final cinematic frame.
samuel_door_broken = false; // Breaking the LE_PWR entrance only arms the interception; crossing inside starts it.
samuel_entrance_x = 0; // Room pixels at the broken doorway centre.
samuel_entrance_top = 0;
samuel_entrance_bottom = 0;
samuel_inside_side = -1; // -1 = room is left of the entrance; inferred from the player's approach when it breaks.
samuel_ambush_group = 0; // Only the broken entrance's marker group is released after the conversation.
samuel_arm_entrance = function(_door, _player)
{
    samuel_door_broken = true;
    samuel_entrance_x = (_door.bbox_left + _door.bbox_right) * 0.5;
    samuel_entrance_top = _door.bbox_top;
    samuel_entrance_bottom = _door.bbox_bottom;
    samuel_ambush_group = _door.ambush_group;
    if (instance_exists(_player)) samuel_inside_side = -sign(_player.x - samuel_entrance_x);
    if (samuel_inside_side == 0) samuel_inside_side = -1;
};
ari_dialogue = [
    "What? How could you be here?",
    "Did you break free on your own?",
    "This can't be... whoever is responsible for this mistake is gonna be dealt with later.",
    "As for you... go back to sleep now."
];

ari_can_start = function(_player)
{
    if (room != LE_PWR) return false;
    if (!samuel_door_broken) return false;
    if ((_player.x - samuel_entrance_x) * samuel_inside_side < 48) return false; // Room pixels inside the doorway; breaking it from outside never starts the scene.
    if (_player.y < samuel_entrance_top - 16 || _player.y > samuel_entrance_bottom + 40) return false;
    var _floor = -1;
    for (var _down = 0; _down <= 8; ++_down) // Room pixels; allow the last few pixels of a natural landing.
    {
        if (collision_point(_player.x, _player.y + _down, o_Block, false, true) != noone)
        {
            _floor = _player.y + _down;
            break;
        }
    }
    if (_floor < 0) return false;
    if (collision_rectangle(_player.x - 13, _floor - 60, _player.x + 14, _floor - 2, o_Block, false, true) != noone) return false;
    var _offsets = [128, 96, 64, 48, 32]; // Room pixels farther inside; Samuel intercepts ahead of the player rather than appearing behind the doorway.
    for (var _i = 0; _i < array_length(_offsets); ++_i)
    {
        var _centre = _player.x + _offsets[_i] * samuel_inside_side;
        if (collision_rectangle(_centre - 16, _floor - 96, _centre + 16, _floor - 2, o_Block, false, true) != noone) continue;
        if (collision_point(_centre - 12, _floor, o_Block, false, true) == noone
            || collision_point(_centre + 12, _floor, o_Block, false, true) == noone) continue;
        ari_hold_x = _player.x;
        ari_floor_y = _floor;
        ari_hold_y = _floor - 1;
        image_xscale = -samuel_inside_side;
        x = _centre - (sprite_get_bbox_left(sprite_index) + sprite_get_bbox_right(sprite_index)) * 0.5 * image_xscale;
        y = _floor - sprite_get_bbox_bottom(sprite_index) - 1;
        return true;
    }
    return false;
};

ari_scene_finished = function()
{
    samuel_encounter_finished = true;
    var _player = ari_player;
    var _group = samuel_ambush_group;
    if (instance_exists(_player)) _player.start_ambush_alarm_sfx(id);
    with (o_DoorEnemySpawn)
    {
        if (ambush_group != _group) continue;
        var _enemy = instance_create_layer(x, y, "Instances", enemy_object);
        if (instance_exists(_player)) array_push(_player.ambush_alarm_enemies, _enemy);
        instance_destroy(); // Consume each existing marker exactly once; the broken doorway cannot spawn it again.
    }
};
