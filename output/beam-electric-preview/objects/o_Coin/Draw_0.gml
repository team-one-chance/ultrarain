// =====================================
// NORMAL COIN
// =====================================

draw_self();


// =====================================
// APEX ANIMATION
// =====================================

if (abs(phy_speed_y) <= split_threshold)
{
    draw_sprite_ext(
        s_Coin_Apex,
        floor(apex_anim_frame),
        x,
        y,
        image_xscale,
        image_yscale,
        image_angle,
        c_white,
        1
    );
}