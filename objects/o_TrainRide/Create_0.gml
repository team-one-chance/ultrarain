depth = 1199;

ride_elapsed = 0;
ride_duration = 12;
arrival_duration = 4;
arrived = false;

scenery_max_speed = 220;
scenery_speed = scenery_max_speed;
scenery_distance = 0;

cruise_duration = max(
    0, ride_duration - arrival_duration
);

// Total distance travelled, including gradual braking.
total_travel_distance =
    scenery_max_speed * cruise_duration
    + scenery_max_speed * arrival_duration * 0.5;

tunnel_a = layer_get_id("Tunnel_A");
tunnel_b = layer_get_id("Tunnel_B");
station_layer = layer_get_id("Station_Arrival");
station_layer_1 = layer_get_id("Station_Arrival_1");

tunnel_repeat_width = room_width;
tunnel_scroll = 0;

if (tunnel_a != -1)
{
    layer_x(tunnel_a, 0);
}

if (tunnel_b != -1)
{
    layer_x(tunnel_b, tunnel_repeat_width);
}

if (station_layer != -1)
{
    // The station approaches from the right.
    layer_x(station_layer, total_travel_distance);
}
if (station_layer_1 != -1)
{
    layer_x(station_layer_1, total_travel_distance);
}