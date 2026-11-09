# Breaker landing camera settings

The Breaker slam pressure burst, wind ribbons, dust, and contact flash have been removed. The landing animation, sound, damage, and camera shake remain.

Camera shake is configured in `scripts/scr_breaker_slam_visuals/scr_breaker_slam_visuals.gml`. This shared configuration applies to both boss phases in TESTING and every gameplay room.

| Setting | Meaning |
| --- | --- |
| `camera_shake_pixels` | Peak camera displacement per axis in room pixels; defaults to 2. Zero disables shake. |
| `camera_shake_seconds` | Duration of the fading landing shake in simulation seconds; defaults to 0.16. |

The settings initialize once per game, so runtime changes survive room transitions. Restart the game after editing source defaults. Rooms must not override the shared configuration.

## Shield bullet feedback

Direct bullets and coin-chain bullets hitting the front of an intact Breaker shield now ricochet at a random angle across nearly the full outward half-circle (up to 89 degrees either side of straight out). The bounce uses the coin shot visual and Breaker's own bullet ricochet sound, travels up to 1200 room pixels, and stops at the first enemy or wall. Its short trail visibly follows the path at 3200 room pixels per second. The outgoing shot deals 25% of the incoming bullet damage. The original shield hit retains its existing damage tuning. An unshielded bash parry plays its separate clash sound.

The `shield_bullet_ricochet` group controls outgoing range and trail length in room pixels, random angle spread in degrees, trail speed in room pixels per second, and damage fraction. These settings apply in TESTING and every gameplay room.
