// Record both bodies before movement and the physics update.
breaker_body_start_left = bbox_left;
breaker_body_start_right = bbox_right;
breaker_body_start_top = bbox_top;
breaker_body_start_bottom = bbox_bottom;
breaker_body_snapshot = [];
with (oEnemy_Breaker) {
    array_push(other.breaker_body_snapshot, {
        boss: id,
        centre: (bbox_left + bbox_right) * 0.5,
        top: bbox_bottom + 1 - (bbox_bottom - bbox_top + 1) * breaker_body_height_fraction,
        bottom: bbox_bottom
    });
}
