// Bind the boarding lock after all room instances exist, before any Step input.
train_find_entrance();

// Extend the existing overhead player boundary down across the entrance until
// Breaker and his queued spawn are gone. Enemies are unaffected by this fixture.
if (!train_boarding_unlocked())
{
    boss_door_barrier = instance_create_depth(train_left - 4, train_floor - 64,
        depth, o_PlayerBarrier, { image_yscale: 2 });
}

// These objects are authored at the destination, but the scenery starts
// one journey away. Capture only fixtures belonging to that station.
if (array_length(station_lights) == 0)
{
    var _types = [o_light_ceil_long_strong, o_MedkitPickup];
    for (var _type_i = 0; _type_i < array_length(_types); _type_i++)
    {
        for (var _i = 0; _i < instance_number(_types[_type_i]); _i++)
        {
            var _item = instance_find(_types[_type_i], _i);
            if (_item.x < train_right || _item.x > 8672
            || _item.y < 1952 || _item.y > train_floor) continue;
            array_push(station_lights, {instance: _item, home_x: _item.x});
        }
    }
}
var _offset = max(0, total_travel_distance - scenery_distance);
for (var _i = 0; _i < array_length(station_lights); _i++)
{
    var _entry = station_lights[_i];
    if (instance_exists(_entry.instance))
        _entry.instance.x = _entry.home_x + _offset;
}
