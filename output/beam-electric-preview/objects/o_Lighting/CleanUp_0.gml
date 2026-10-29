if (surface_exists(light_surface)) surface_free(light_surface);
if (surface_exists(bloom_surface_a)) surface_free(bloom_surface_a);
if (surface_exists(bloom_surface_b)) surface_free(bloom_surface_b);
if (bloom_camera != -1) camera_destroy(bloom_camera);
if (surface_exists(pixelation_surface)) surface_free(pixelation_surface);
if (pixelation_camera != -1) camera_destroy(pixelation_camera);
