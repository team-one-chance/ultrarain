// Only explode on death; ordinary removal during transitions is silent.
if (pHP <= 0)
{
    if (room == LE_TUTORIAL_WIP)
    {
        if (!variable_global_exists("tutorial_death_count")) global.tutorial_death_count = 0;
        global.tutorial_death_count++; // Count actual deaths, excluding ordinary room transitions and manual restarts.
    }
    audio_play_sound(sfxPDeath, 1, false);
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

// The persistent room may recreate the player after a grinder death or travel.
if (player_room_layer != -1 && layer_exists(player_room_layer))
    layer_depth(player_room_layer, player_room_layer_depth);
