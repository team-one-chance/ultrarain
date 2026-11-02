if (under_revealed)
{
    exit;
}

var player = instance_find(o_Player, 0);

if (player == noone)
{
    exit;
}

// This object has no sprite, so use an explicit rectangular trigger region.
var trigger_left = x - reveal_trigger_width * 0.5;
var trigger_right = x + reveal_trigger_width * 0.5;
var trigger_top = y - reveal_trigger_height * 0.5;
var trigger_bottom = y + reveal_trigger_height * 0.5;

var player_touches_trigger =
    player.bbox_right >= trigger_left
    && player.bbox_left <= trigger_right
    && player.bbox_bottom >= trigger_top
    && player.bbox_top <= trigger_bottom;

if (player_touches_trigger)
{
    under_revealed = true;

    for (var i = 0; i < array_length(under_background_layers); i++)
    {
        var background_layer = under_background_layers[i];

        if (background_layer != -1)
        {
            layer_set_visible(background_layer, true);
        }
    }
}
