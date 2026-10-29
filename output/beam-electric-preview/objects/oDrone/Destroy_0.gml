// Ordinary removal during room transitions should remain silent.
if (ehp <= 0)
{
    world_sfx_play(sfxDroneDeath, x, y);

    instance_create_depth(
        (bbox_left + bbox_right) * 0.5,
        (bbox_top + bbox_bottom) * 0.5,
        depth - 1,
        oDroneExplosion
    );

    instance_create_depth(
        x, y, clamp(depth + 1, -15999, 15999), oDroneWreckage,
        {
            wreck_sprite: normal_sprite,
            wreck_frame: floor(image_index) mod max(1, sprite_get_number(normal_sprite)),
            wreck_scale_x: image_xscale,
            wreck_scale_y: image_yscale,
            wreck_angle: image_angle
        }
    );
}

event_inherited();
