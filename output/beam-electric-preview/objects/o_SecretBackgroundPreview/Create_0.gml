depth = 699;
// A local view of the existing far-background tiles, independent of BG_Far visibility.
preview_width = 1664;
preview_height = 1120;
preview_fade = 128;
preview_finished = false;
preview_layer = layer_get_id("BG_Far");
preview_map = preview_layer == -1 ? -1 : layer_tilemap_get_id(preview_layer);
