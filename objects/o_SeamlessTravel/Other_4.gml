// Track which rooms this controller has already visited.
if (!variable_instance_exists(id, "physics_visited_rooms"))
{
    physics_visited_rooms = {};
}

var _room_key = room_get_name(room);

var _returning = variable_struct_exists(
    physics_visited_rooms,
    _room_key
);

variable_struct_set(
    physics_visited_rooms,
    _room_key,
    true
);

// First visits already build fixtures through Create.
// Returning to a persistent room requires rebuilding them.
if (_returning && room_persistent)
{
    seamless_rebuild_room_physics();
}
// ROOM START: all room instances have completed Create.
if (is_undefined(pending)) exit;
if (pending.destination_room != room) exit;
var _transfer = pending;
pending = undefined;

var _arrival = noone;
for (var _i = 0; _i < instance_number(o_SeamlessGate); _i++)
{
    var _gate = instance_find(o_SeamlessGate, _i);
    if (_gate.connection_id == _transfer.connection_id)
    {
        _arrival = _gate;
        break;
    }
}
if (!instance_exists(_arrival))
{
    show_debug_message("Seamless entrance: missing ARRIVAL marker " + _transfer.connection_id);
    exit;
}
var _old_player = instance_find(o_Player, 0);
// Keep each room's acoustic setup and encounter state in that room. In
// particular, the tutorial lab's wire settings must not leak into other rooms.
var _room_audio = {};
var _room_audio_fields = [
    "electric_wires_delayed_object", "electric_wires_activation_platform",
    "electric_wires_lab_door", "electric_wires_second_unlocked",
    "electric_wires_lab_entered", "ambush_alarm_doors", "ambush_alarm_enemies"
];

if (instance_exists(_old_player))
{
    for (var _i = 0; _i < array_length(_room_audio_fields); _i++)
    {
        var _name = _room_audio_fields[_i];
        variable_struct_set(_room_audio, _name,
            variable_instance_get(_old_player, _name));
    }
    // Remove the stored player's old chip visuals.
    with (o_ChipAttachment)
    {
        if (!is_healing && target == _old_player)
        {
            instance_destroy();
        }
    }

    // Ordinary removal is silent in the player's Destroy event.
    with (_old_player)
    {
        instance_destroy();
    }
}

// Create builds a fresh physics body before we restore any properties.
// Tutorial Create resets fresh-run history; a seamless return is the same run.
var _took_damage = global.demo_took_damage;
var _used_healing = global.demo_used_healing;
var _player = instance_create_depth(
    _arrival.x,
    _arrival.y,
    0,
    o_Player
);
global.demo_took_damage = _took_damage;
global.demo_used_healing = _used_healing;

seamless_restore(_player, _arrival, _transfer);
var _audio_names = variable_struct_get_names(_room_audio);
for (var _i = 0; _i < array_length(_audio_names); _i++)
{
    var _name = _audio_names[_i];
    variable_instance_set(_player, _name, variable_struct_get(_room_audio, _name));
}
_player.depth = layer_get_depth(layer_get_id("Instances")) - 1;

item_controllers_update(_player);

transition_cooldown = 0.3;
