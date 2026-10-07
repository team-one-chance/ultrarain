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
