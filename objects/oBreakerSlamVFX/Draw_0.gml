var _lighting = instance_find(o_Lighting, 0); // Optional room lighting controller; TESTING can also render directly.
defer_to_lighting = false; // Recomputed each frame so freecam and lighting toggles cannot hide the effect.
if (instance_exists(_lighting) && view_enabled)
{
    // Controllers created by depth (as in TESTING) can have layer = -1, meaning no named layer.
    var _renderer_layer_visible = _lighting.layer == -1 || layer_get_visible(_lighting.layer);
    defer_to_lighting = _lighting.enabled && _lighting.visible && _renderer_layer_visible
        && view_camera[view_current] != -1 && surface_exists(_lighting.light_surface)
        && !(variable_global_exists("dev_freecam") && global.dev_freecam);
}
if (!defer_to_lighting) draw_pressure_burst();
