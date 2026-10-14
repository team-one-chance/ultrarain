// Both directions use the same frame number; the right sprite includes
// a 22.5-degree tooth offset, and its frames rotate in the opposite direction.
image_speed = 0;
if (!variable_global_exists("grinder_animation_time")) {
    global.grinder_animation_time = 0;
}
image_index = floor(global.grinder_animation_time * 24) mod 72;
