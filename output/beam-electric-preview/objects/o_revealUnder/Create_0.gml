// The trigger is centered on its room-editor position. Adjust these values
// in this event if the opening needs a larger or smaller activation area.
reveal_trigger_width = 64;
reveal_trigger_height = 64;
under_revealed = false;

under_background_layers = [
    layer_get_id("BG_Middle"),
    layer_get_id("BG_Far")
];

for (var i = 0; i < array_length(under_background_layers); i++)
{
    var background_layer = under_background_layers[i];

    if (background_layer != -1)
    {
        layer_set_visible(background_layer, false);
    }
}
