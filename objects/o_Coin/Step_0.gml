if (is_pinned)
{
    var _pin_dt = max(
        0,
        (variable_global_exists("dev_delta_time")
            ? global.dev_delta_time
            : delta_time) / 1000000
    );

    pin_time_left -= _pin_dt;

    if (pin_time_left <= 0)
    {
        // Release the player's active-coin reference.
        if (instance_exists(pin_owner))
        {
            if (pin_owner.pinned_coin == id)
                pin_owner.pinned_coin = noone;
        }

        is_pinned = false;
        pin_owner = noone;
        pin_was_supporting = false;
        pin_drop_remaining = 0;

        // Return to ordinary physics and gravity.
        phy_position_x = pin_x;
        phy_position_y = pin_y;
        phy_active = true;
        phy_speed_x = 0;
        phy_speed_y = 0;
    }
    else
    {
        var _standing_player = instance_find(o_Player, 0);
        var _occupied = pin_player_on_top(_standing_player);

        // Upward movement immediately after standing on the coin.
        if (pin_was_supporting
        && instance_exists(_standing_player))
        {
            if (_standing_player.phy_speed_y < 0)
            {
                pin_drop_remaining = pin_jump_drop_distance;
            }
        }

        pin_was_supporting = _occupied;

        if (pin_drop_remaining > 0)
        {
            var _drop = min(
                pin_drop_remaining,
                pin_jump_drop_speed * _pin_dt
            );

            pin_y += _drop;
            pin_drop_remaining -= _drop;
        }
        else if (_occupied)
        {
            var _sink = pin_sink_speed * _pin_dt;

            pin_y += _sink;
            _standing_player.phy_position_y += _sink;
        }

        phy_position_x = pin_x;
        phy_position_y = pin_y;
    }
}

// =====================================
// COIN
// =====================================
// =====================================
// COIN BLOCK COLLISION
// =====================================

if (is_pinned)
{
    // Pinned coin:
    // ANY contact with level geometry destroys it.
    if (place_meeting(x, y, [o_Block, o_Block_scary]))
    {
        instance_destroy();
    }
}
else
{
    // =================================
    // NORMAL COIN
    // =================================

    // Check ONLY directly underneath the
    // centre of the coin.
    var _coin_center_x =
        (bbox_left + bbox_right) * 0.5;

    var _ground =
        collision_point(
            _coin_center_x,
            bbox_bottom + 2,
            o_Block,
            false,
            true 
        );


    // Only destroy when actually landing.
    if (
        _ground != noone
        && phy_speed_y >= 0
    )
    {
        instance_destroy();
    }
}
/*
// Destroy when touching an enemy
if (place_meeting(x, y, oEnemy_Scout))
{
    instance_destroy();
}
*/
// =====================================
// APEX ANIMATION
// =====================================

if (abs(phy_speed_y) <= split_threshold)
{
    apex_anim_frame +=
        apex_anim_speed
        * ((variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000);

    if (apex_anim_frame >= sprite_get_number(s_Coin_Apex))
    {
        apex_anim_frame = 0;
    }
}
else
{
    apex_anim_frame = 0;
}