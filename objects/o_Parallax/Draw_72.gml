var cam = view_camera[0];

if (cam == -1)
{
    exit;
}

var cam_x = camera_get_view_x(cam);
var cam_y = camera_get_view_y(cam);

// Keep the initial layout where you painted it.
if (!parallax_ready)
{
    parallax_camera_start_x = cam_x;
    parallax_camera_start_y = cam_y;
    parallax_ready = true;
}

var camera_delta_x = cam_x - parallax_camera_start_x;
var camera_delta_y = cam_y - parallax_camera_start_y;

for (var i = 0; i < array_length(parallax_layers); i++)
{
    var entry = parallax_layers[i];

    if (entry.layer_id == -1)
    {
        continue;
    }

    layer_x(
        entry.layer_id,
        round(entry.start_x
            + camera_delta_x * (1 - entry.speed_x))
    );

    layer_y(
        entry.layer_id,
        round(entry.start_y
            + camera_delta_y * (1 - entry.speed_y))
    );
}