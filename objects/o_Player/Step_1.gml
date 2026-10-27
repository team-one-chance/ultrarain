// Record both bodies before movement and the physics update.
// Match the physics fixture, independent of animation bounds and facing.
breaker_body_start_left = phy_position_x + 0.5 - player_collider_half_width;
breaker_body_start_right = phy_position_x + 0.5 + player_collider_half_width;
breaker_body_start_top = phy_position_y - player_collider_height;
breaker_body_start_bottom = phy_position_y;
breaker_body_snapshot = [];
with (oEnemy_Breaker) {
    array_push(other.breaker_body_snapshot, {
        boss: id,
        airborne_attack: breaker_contact_active(),
        centre: (bbox_left + bbox_right) * 0.5,
        top: bbox_bottom + 1 - (bbox_bottom - bbox_top + 1) * breaker_body_height_fraction,
        bottom: bbox_bottom
    });
}
