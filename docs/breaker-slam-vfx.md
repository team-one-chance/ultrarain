# Breaker landing camera settings

The Breaker slam pressure burst, wind ribbons, dust, and contact flash have been removed. The landing animation, sound, damage, and camera shake remain.

Camera shake is configured in `scripts/scr_breaker_slam_visuals/scr_breaker_slam_visuals.gml`. This shared configuration applies to both boss phases in TESTING and every gameplay room.

| Setting | Meaning |
| --- | --- |
| `camera_shake_pixels` | Peak camera displacement per axis in room pixels; defaults to 2. Zero disables shake. |
| `camera_shake_seconds` | Duration of the fading landing shake in simulation seconds; defaults to 0.16. |

The settings initialize once per game, so runtime changes survive room transitions. Restart the game after editing source defaults. Rooms must not override the shared configuration.
