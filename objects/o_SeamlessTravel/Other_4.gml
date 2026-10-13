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

if (instance_exists(_old_player))
{
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
var _player = instance_create_depth(
    _arrival.x,
    _arrival.y,
    0,
    o_Player
);

seamless_restore(_player, _arrival, _transfer);
_player.depth = layer_get_depth(layer_get_id("Instances")) - 1;
transition_cooldown = 0.3;