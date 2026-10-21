// =====================================
// COIN ANCHOR - PINNED STATE
// =====================================

if (is_pinned)
{
    if (instance_exists(pin_owner))
    {
        // Stop all coin movement.
        phy_speed_x = 0;
        phy_speed_y = 0;

        phy_angular_velocity = 0;


        // Follow the player.
        phy_position_x =
            pin_owner.x
            + (
                pin_owner.pinned_coin_offset_x
                * pin_owner.image_xscale
            );

        phy_position_y =
            pin_owner.y
            + pin_owner.pinned_coin_offset_y;
    }
    else
    {
        is_pinned = false;
        pin_owner = noone;
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