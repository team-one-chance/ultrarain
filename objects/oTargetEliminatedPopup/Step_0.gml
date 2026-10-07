popup_age += delta_time / 1000000;
if (popup_age >= popup_duration)
{
    instance_destroy();
    exit;
}

// Follow the enemy's head while the notification gently floats upward.
if (instance_exists(enemy_id))
{
    x = (enemy_id.bbox_left + enemy_id.bbox_right) * 0.5;
    y = enemy_id.bbox_top - popup_head_gap - min(popup_age * 8, 10);
}
