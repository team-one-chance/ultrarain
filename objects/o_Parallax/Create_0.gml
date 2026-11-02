parallax_ready = false;

// Maximum displacement from the painted room layout, in room pixels.
// Use -1 for unlimited travel, or 0 to lock an axis in place.
parallax_layers = [
    {
        layer_id: layer_get_id("BG_Far"),
        speed_x: 0.70,
        speed_y: 0.90,
        max_offset_x: -1,
        max_offset_y: -1,
        start_x: 0,
        start_y: 0
    },
    {
        layer_id: layer_get_id("BG_Middle"),
        // 1 means no parallax offset: keep the painted room position.
        speed_x: 1,
        speed_y: 1,
        max_offset_x: 64,
        max_offset_y: 32,
        start_x: 0,
        start_y: 0
    }
];

// The pre-tutorial folder contains three separate tile layers. Move them
// together, with a larger camera-relative offset for its vast cyberspace.
if (room == r_preTutorial)
{
    parallax_layers = [];
    var far_layer_names = ["BG_Far_Red", "BG_Far_Blue", "BG_Far_Green"];
    for (var i = 0; i < array_length(far_layer_names); i++)
    {
        var far_layer = layer_get_id(far_layer_names[i]);
        if (far_layer == -1) continue;

        layer_shader(far_layer, sh_PreTutorialFarDim);
        array_push(parallax_layers, {
            layer_id: far_layer,
            speed_x: 0.15, // 55% of horizontal camera travel offsets the background.
            speed_y: 0.30, // 30% of vertical camera travel offsets the background.
            max_offset_x: -1, // Unlimited horizontal offset, in room pixels.
            max_offset_y: -1, // Unlimited vertical offset, in room pixels.
            start_x: 0,
            start_y: 0
        });
    }
}

for (var i = 0; i < array_length(parallax_layers); i++)
{
    var entry = parallax_layers[i];

    if (entry.layer_id != -1)
    {
        entry.start_x = layer_get_x(entry.layer_id);
        entry.start_y = layer_get_y(entry.layer_id);
    }
}

// Keep pixel-art tile edges crisp at fractional camera positions and display scales.
var use_nearest_filter = function()
{
    gpu_set_texfilter(false);
};

for (var i = 0; i < array_length(parallax_layers); i++)
{
    var background_layer = parallax_layers[i].layer_id;

    if (background_layer != -1)
    {
        layer_script_begin(background_layer, use_nearest_filter);
        layer_script_end(background_layer, use_nearest_filter);
    }
}
