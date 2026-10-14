var cam = view_camera[0];

if (cam == -1)
{
    exit;
}

var cam_x = camera_get_view_x(cam);
var cam_y = camera_get_view_y(cam);

// Anchor the painted layout to the spawn view, not the camera's initial
// room-editor position. o_CAMERA eases from that position toward the player.
if (!parallax_ready)
{
    parallax_camera_start_x = cam_x;
    parallax_camera_start_y = cam_y;

    var player = instance_find(o_Player, 0);
    if (player != noone)
    {
        // Match the framing used by o_CAMERA.
        parallax_camera_start_x = player.x - camera_get_view_width(cam) / 2;
        parallax_camera_start_y = player.y - camera_get_view_height(cam) / 1.4;
    }

    parallax_ready = true;
}

var camera_delta_x = cam_x - parallax_camera_start_x;
var camera_delta_y = cam_y - parallax_camera_start_y;
var train_ride = instance_find(o_TrainRide, 0);

for (var i = 0; i < array_length(parallax_layers); i++)
{
    var entry = parallax_layers[i];

    if (entry.layer_id == -1)
    {
        continue;
    }

    var offset_x = camera_delta_x * (1 - entry.speed_x);
    var offset_y = camera_delta_y * (1 - entry.speed_y);

    // Negative limits leave that axis unrestricted.
    if (entry.max_offset_x >= 0)
    {
        offset_x = clamp(offset_x, -entry.max_offset_x, entry.max_offset_x);
    }
    if (entry.max_offset_y >= 0)
    {
        offset_y = clamp(offset_y, -entry.max_offset_y, entry.max_offset_y);
    }

    // The train owns BG_Far's horizontal position from departure onward.
    var train_controls_x = false;
    if (instance_exists(train_ride))
    {
        train_controls_x = train_ride.ride_started
            && entry.layer_id == train_ride.bgfar_layer;
    }
    if (!train_controls_x)
    {
        layer_x(
            entry.layer_id,
            round(entry.start_x
                + offset_x)
        );
    }

    layer_y(
        entry.layer_id,
        round(entry.start_y
            + offset_y)
    );
}
