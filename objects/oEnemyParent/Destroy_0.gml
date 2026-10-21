// Ordinary removal and room teardown must not produce death effects.
if (variable_instance_exists(id, "ehp") && ehp <= 0)
{
    instance_create_depth(
        (bbox_left + bbox_right) * 0.5,
        (bbox_top + bbox_bottom) * 0.5,
        clamp(depth - 1, -15999, 15999),
        oEnemyExplosion,
        { fx_miniboss: object_index == oMiniBoss || object_is_ancestor(object_index, oMiniBoss) }
    );
}
