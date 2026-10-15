if (!enabled || !global.dev_freecam || world_frozen) exit;

// Hide only during rendering. Reveal triggers retain their actual layer states.
freecam_layer_states = [];
var _layers = layer_get_all();

for (var _i = 0; _i < array_length(_layers); _i++)
{
    var _layer = _layers[_i];
    var _name = string_lower(layer_get_name(_layer));

    if (string_pos("dark_", _name) == 1
    || string_pos("black", _name) > 0)
    {
        array_push(freecam_layer_states, {
            layer: _layer,
            was_visible: layer_get_visible(_layer)
        });
        layer_set_visible(_layer, false);
    }
}
