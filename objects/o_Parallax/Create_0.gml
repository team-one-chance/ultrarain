parallax_ready = false;

parallax_layers = [
    {
        layer_id: layer_get_id("BG_Far"),
        speed_x: 0.80,
        speed_y: 0.95,
        start_x: 0,
        start_y: 0
    },
    {
        layer_id: layer_get_id("BG_Middle"),
        speed_x: 0.90,
        speed_y: 0.98,
        start_x: 0,
        start_y: 0
    }
];

for (var i = 0; i < array_length(parallax_layers); i++)
{
    var entry = parallax_layers[i];

    if (entry.layer_id != -1)
    {
        entry.start_x = layer_get_x(entry.layer_id);
        entry.start_y = layer_get_y(entry.layer_id);
    }
}

var filter_on = function()
{
    gpu_set_texfilter(true);
};

var filter_off = function()
{
    gpu_set_texfilter(false);
};

for (var i = 0; i < array_length(parallax_layers); i++)
{
    var background_layer = parallax_layers[i].layer_id;

    if (background_layer != -1)
    {
        layer_script_begin(background_layer, filter_on);
        layer_script_end(background_layer, filter_off);
    }
}