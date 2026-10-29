if (preview_finished) exit;
var _player = instance_find(o_Player, 0);
var _cover = layer_get_id("dark_secretarea");
if ((_cover != -1 && !layer_get_visible(_cover))
|| (instance_exists(_player) && _player.y >= 1280))
{
    preview_finished = true;
    visible = false;
}
