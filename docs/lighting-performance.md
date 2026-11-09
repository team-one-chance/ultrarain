# Lighting performance

The shared `o_Lighting` controller applies the same optimization settings in
TESTING and gameplay rooms. Settings are documented in its Create event:

- `light_resolution = 0.5`: maximum illumination buffer dimensions relative to
  the world camera. `light_pixel_budget = 259200` further caps the total pixels
  to the former 720 x 360 light map, preserving aspect ratio. The 3:1 view uses
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

Lower-resolution glow can soften or reduce very thin highlights; the original
sharp sprites are still drawn normally. Increase `bloom_resolution` if needed
after checking the thin cyan player accents on the target display.

## Wide view and rendering budget

Every room's active view is 2160 x 720 (3:1), previously 1440 x 720 (2:1).
Initial horizontal camera positions move left by 360 pixels to preserve their
centers. Player following, train framing, and seamless transitions already use
the camera dimensions, so the extra 720 world pixels are shared between left
and right without increasing the vertical field of view.

The active viewport is also 2160 x 720, down from 3240 x 1080. This removes the
previous 1.5x rendering scale and reduces main-buffer pixels from 3,499,200 to
1,555,200. At `bloom_resolution = 0.5`, bloom buffers drop from 1620 x 540 to
1080 x 360. Light maps stay within their previous pixel budget. More visible
objects may still add draw calls and gameplay work, so target-device frame-time
checks remain necessary.

The display controller fits a 3:1 window within 90% of the display, up to
2160 x 720. Existing fullscreen and F11 behavior are retained. Fullscreen uses
aspect-preserving scaling with black bars on displays that are not 3:1. The
logical GUI is 3240 x 1080 to preserve its authored vertical layout while
extending the horizontal space; it does not enlarge the world render target.

## Runner checks

Compile the Windows target, then compare the same enemy-room camera position on
the affected iGPU before and after the change. Use the same display resolution,
pixelization preference, enemies, and frame cap. Record frame times during combat
and with no enemies visible; reduced buffer work is not an FPS measurement.

Check ceiling cones and lamp halos while panning, rotated/flipped lamps, lamp
flicker and breakage, Scout/Drone glow entering and leaving the view, player cyan
accents, impacts, and lava behind its cover. Also check resizing/fullscreen,
camera zoom, room transitions, and retry so surface recreation is exercised.
For the 3:1 view, also check left/right aim and crosshair alignment, menu and
inventory hit targets, HUD layout, train framing, and seamless gate crossings.
