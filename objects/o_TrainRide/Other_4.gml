if (station_layer_2 != -1)
{
    // Instance positions will control movement.
    layer_x(station_layer_2, 0);

    // Capture after every room instance has finished Create.
    if (array_length(station_lights) == 0)
    {
        var _elements = layer_get_all_elements(station_layer_2);

        for (var _i = 0; _i < array_length(_elements); _i++)
        {
            if (layer_get_element_type(_elements[_i])
                != layerelementtype_instance)
            {
                continue;
            }

            var _light = layer_instance_get_instance(_elements[_i]);
            if (!instance_exists(_light)) continue;

            array_push(station_lights, {
                instance: _light,
                home_x: _light.x
            });
        }
    }

    var _offset = max(
        0,
        total_travel_distance - scenery_distance
    );

    for (var _i = 0; _i < array_length(station_lights); _i++)
    {
        var _entry = station_lights[_i];

        if (instance_exists(_entry.instance))
        {
            _entry.instance.x = _entry.home_x + _offset;
        }
    }
}