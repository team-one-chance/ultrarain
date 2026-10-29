item_controllers_update(id);
parry_breaker_windows = []; // Only a newly accepted press this frame can parry Breaker's steady green/yellow interval.
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
        bash_serial: breaker_bash_serial, // Attack counter identifies the exact bash shown in the previous frame.
        parry_state: breaker_melee_parry_open()
            ? (breaker_unshielded ? ParryState.HALF : ParryState.FULL)
            : ParryState.UNPARRYABLE, // Snapshot before either Step advances: matches the steady eye color the player saw.
        airborne_attack: breaker_contact_active(),
        centre: (bbox_left + bbox_right) * 0.5,
        top: bbox_bottom + 1 - (bbox_bottom - bbox_top + 1) * breaker_body_height_fraction,
        bottom: bbox_bottom
    });
}
