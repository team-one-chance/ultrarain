// Ordinary removal and room teardown must not produce death effects.
if (variable_instance_exists(id, "ehp") && ehp <= 0)
{
    var _breaker = object_index == oEnemy_Breaker || object_is_ancestor(object_index, oEnemy_Breaker);
    if (_breaker) {
        world_sfx_play(sfxBreakerDeath, x, y, 2.5, 1, 1280);
        breaker_spawn_wreckage(false);
        // A kill from behind can leave the shield intact until death.
        if (!breaker_shield_debris_spawned) breaker_spawn_wreckage(true);
    }
    var _scout = object_index == oEnemy_Scout || object_index == oEnemy_Scout_mini
        || object_is_ancestor(object_index, oEnemy_Scout)
        || object_is_ancestor(object_index, oEnemy_Scout_mini);
    if (_scout)
    {
        instance_create_depth((bbox_left + bbox_right) * 0.5, bbox_bottom + 1,
            clamp(depth + 1, -15999, 15999), oScoutWreckage,
            {
                wreck_scale_x: scout_facing * scout_scale,
                wreck_scale_y: scout_scale,
                wreck_angle: image_angle
            });
    }
    instance_create_depth(
        (bbox_left + bbox_right) * 0.5,
        (bbox_top + bbox_bottom) * 0.5,
        clamp(depth - 1, -15999, 15999),
        oEnemyExplosion,
        {
            fx_miniboss: _breaker,
            fx_scout_size: _scout ? max(bbox_right - bbox_left + 1, bbox_bottom - bbox_top + 1) : 0
        }
    );
}
