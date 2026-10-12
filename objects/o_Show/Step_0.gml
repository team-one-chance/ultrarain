var trigger_half_width = max(0, reveal_trigger_width) * 0.5;
var trigger_half_height = max(0, reveal_trigger_height) * 0.5;

var player = collision_rectangle(
    x - trigger_half_width, y - trigger_half_height,
    x + trigger_half_width, y + trigger_half_height,
    o_Player, false, true
);

if (player != noone)
{
    var target_layer = layer_get_id(layer_to_hide);

    // Ignore missing layer names safely.
    if (target_layer != -1)
    {
        layer_set_visible(target_layer, true);
        layer_hidden = false;
    }
}
