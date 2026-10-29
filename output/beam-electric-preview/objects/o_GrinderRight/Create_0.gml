// The right sprite includes the half-tooth offset needed to mesh with the left.
image_speed = 0;
if (!variable_global_exists("grinder_animation_time")) {
    global.grinder_animation_time = 0;
}
image_index = floor(global.grinder_animation_time * 24) mod 72;
