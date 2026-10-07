// Only explode on death; ordinary removal during transitions is silent.
if (pHP <= 0)
{
    if (!instance_exists(oGameOver))
    {
        // Stay within GameMaker's drawable layer range (-16000 to 16000).
        instance_create_depth(0, 0, -15000, oGameOver);
    }

    // Includes every enemy subtype through the shared parent object.
    with (oEnemyParent)
    {
        var popup = instance_create_depth(
            (bbox_left + bbox_right) * 0.5,
            bbox_top - 24,
            -10000,
            oTargetEliminatedPopup
        );
        popup.enemy_id = id;
    }

    instance_create_depth(
        (bbox_left + bbox_right) * 0.5,
        (bbox_top + bbox_bottom) * 0.5,
        depth - 1,
        oPlayerExplosion
    );
}
