for (var _i = 0; _i < array_length(wire_contact_lights); _i++)
{
    var _light = wire_contact_lights[_i].light;

    if (instance_exists(_light))
        instance_destroy(_light);
}