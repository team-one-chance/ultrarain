# Lighting performance

The main and pause menus offer **Graphics: Performance / Quality**, independently
of **Aspect ratio: Original (2:1) / Ultrawide (3:1)**. Performance is the default
for lower-end devices, including PCs without a dedicated graphics card. Quality
restores the higher-resolution scene, illumination, and glow. Choices apply
without restarting and are saved between launches.

The shared `display_settings_profile()` in `scr_menu_settings` documents the
budgets used by `o_DisplaySettings` and `o_Lighting` in TESTING and gameplay:

| Buffer | Performance, Original | Performance, Ultrawide | Quality, Original | Quality, Ultrawide |
| --- | --- | --- | --- | --- |
| Scene | 1440 x 720 | 2160 x 720 | 2160 x 1080 | 3240 x 1080 |
| Illumination | 720 x 360 | 881 x 293 | 1440 x 720 | 2160 x 720 |
| Bloom | 720 x 360 | 1080 x 360 | 2160 x 1080 | 3240 x 1080 |

Performance uses these optimizations:

- `light_resolution = 0.5`: maximum illumination buffer dimensions relative to
  the world camera. `light_pixel_budget = 259200` further caps the total pixels
  to a 720 x 360 pixel budget, preserving aspect ratio. The 3:1 view uses
  an 881 x 293 light map. Linear filtering smooths the composite; scene sprites
  and the HUD retain their resolution.
- `bloom_resolution = 0.5`: bloom buffer dimensions relative to the application
  surface, capped at world-camera dimensions to avoid excessive work at high
  display resolutions. Blur radii remain in room pixels. At half application
  resolution, each blur pass shades one quarter as many pixels.
- Enemy bloom collects visible Scout/Drone sources, including padding for scaled
  artwork, attack shake, and blur spill. With no visible sources it skips enemy
  extraction, both blur passes, and the composite. Hidden enemies do not glow.
- Ceiling cones use the transformed trapezoid bounds for culling, including
  rotated and negatively scaled lamps. Lamp strength, reach, color, flicker,
  and breakage behavior are unchanged.

Quality uses `light_resolution = 1`, a light pixel budget covering the camera,
and `bloom_resolution = 1` without the world-resolution bloom cap. Off-screen
source culling remains enabled in both modes. Existing light and bloom surfaces
recreate themselves at the new dimensions after changing modes, including after
resuming from pause. Lower-resolution glow can soften very thin highlights;
check the player cyan accents on the target display in both modes.

## Wide view and rendering budget

The Ultrawide camera view is 2160 x 720 (3:1); Original is 1440 x 720 (2:1).
Initial horizontal camera positions move left by 360 pixels to preserve their
centers. Player following, train framing, and seamless transitions already use
the camera dimensions, so the extra 720 world pixels are shared between left
and right without increasing the vertical field of view.

With Ultrawide, Performance's active viewport is 2160 x 720, compared with
Quality's 3240 x 1080. Performance removes the
previous 1.5x rendering scale and reduces main-buffer pixels from 3,499,200 to
1,555,200. At `bloom_resolution = 0.5`, bloom buffers drop to
1080 x 360. Light maps stay within their previous pixel budget. More visible
objects may still add draw calls and gameplay work, so target-device frame-time
checks remain necessary.

The display controller fits the selected ratio within 90% of the display, up to
720 pixels high. Existing fullscreen and F11 behavior are retained. Fullscreen
uses aspect-preserving scaling with black bars when the monitor's ratio differs.
The logical GUI height stays at 1080; its width follows the selected aspect ratio.

## Runner checks

Compile the Windows target, then compare the same enemy-room camera position on
the affected integrated GPU in Performance and Quality. Use the same display resolution,
pixelization preference, enemies, and frame cap. Record frame times during combat
and with no enemies visible; reduced buffer work is not an FPS measurement.

Check ceiling cones and lamp halos while panning, rotated/flipped lamps, lamp
flicker and breakage, Scout/Drone glow entering and leaving the view, player cyan
accents, impacts, and lava behind its cover. Also check resizing/fullscreen,
camera zoom, room transitions, and retry so surface recreation is exercised.
For the 3:1 view, also check left/right aim and crosshair alignment, menu and
inventory hit targets, HUD layout, train framing, and seamless gate crossings.
Exercise all four graphics/aspect combinations, including toggling while paused,
retrying, entering previously visited rooms, and relaunching the game.
