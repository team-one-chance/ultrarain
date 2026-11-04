# Display framing

Every room uses a 2160 x 720 camera view and a 3240 x 1080 output viewport.
Both use a 3:1 aspect ratio, with the same 1.5 output pixels per world pixel
on each axis, so the game image is not distorted.

The previous camera view was 1440 x 720. Keeping the 720-world-pixel height
preserves the vertical framing and scale on a screen of the same height.
The extra 720 world pixels reveal 360 more pixels on either side of the
camera center. Initial room camera positions are shifted left by 360 world
pixels to keep that center unchanged. The player-follow camera already
centers using the actual camera width, including during train rides and
seamless room transitions.

The active view in each room's `.yy` file contains these settings:

- `wview` / `hview`: visible world width / height in world pixels.
- `wport` / `hport`: output width / height in pixels; keep their ratio equal
  to the camera ratio to avoid stretching.
- `xview`: initial left edge in world pixels; subtract half the added camera
  width when widening the view to preserve the initial center.

Check in the GameMaker Windows runner on a 3:1 display: confirm circles and
sprites retain their proportions, the vertical view matches the old 2:1
framing, and more level is visible on both sides. Exercise the boot menu,
TESTING, tutorial, train ride, seamless gates, and fullscreen toggling (F11).
A display with a different aspect ratio can still have black borders.
