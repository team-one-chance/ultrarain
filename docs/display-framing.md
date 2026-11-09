# Display framing

Main menu and pause menu **Settings** expose two independent display choices:

- **Graphics: Performance / Quality** selects the rendering and lighting budget.
- **Aspect ratio: Original (2:1) / Ultrawide (3:1)** selects the camera framing.

Both apply without restarting and are saved in `display.ini` in GameMaker's
save directory. Defaults remain Performance and Ultrawide. The shared
`display_settings_profile()` in `scr_menu_settings` defines every budget;
`o_DisplaySettings` applies it at room start and maintains it after surface loss.
Direct gameplay-room launches create the controller from `o_Player` as needed.

| Aspect ratio | Camera (world pixels) | Performance output | Quality output | Logical GUI |
| --- | --- | --- | --- | --- |
| Original (2:1) | 1440 x 720 | 1440 x 720 | 2160 x 1080 | 2160 x 1080 |
| Ultrawide (3:1) | 2160 x 720 | 2160 x 720 | 3240 x 1080 | 3240 x 1080 |

Output and camera ratios always match. Quality restores the former 1.5x
rendering scale; Performance draws one output pixel per world pixel.
The logical GUI height remains 1080 regardless of graphics quality. See
[lighting performance](lighting-performance.md) for the lighting budget.

The previous camera view was 1440 x 720. Keeping the 720-world-pixel height
preserves the vertical framing and scale on a screen of the same height.
The extra 720 world pixels reveal 360 more pixels on either side of the
camera center. Switching aspect ratio preserves the current camera center;
the authored room views remain wide, with initial positions shifted left by
360 world pixels. The player-follow camera already
centers using the actual camera width, including during train rides and
seamless room transitions.

The active view in each room's `.yy` file supplies initial framing, overridden
at runtime by the saved profile:

- `wview` / `hview`: visible world width / height in world pixels.
- `wport` / `hport`: output width / height in pixels; keep their ratio equal
  to the camera ratio to avoid stretching.
- `xview`: initial left edge in world pixels; subtract half the added camera
  width when widening the view to preserve the initial center.

Check all four settings combinations in the GameMaker Windows runner: confirm circles and
sprites retain their proportions, the vertical view matches the old 2:1
framing, and more level is visible on both sides. Exercise the boot menu,
TESTING, tutorial, train ride, seamless gates, and fullscreen toggling (F11).
A display with a different aspect ratio can still have black borders. Check
switching in the main and pause menus, Controls and Back navigation, mouse hit
targets after resizing, room retries, and persistence after exiting and relaunching.
While paused, the captured scene keeps its original proportions; the live scene
uses the new framing and lighting when resumed.
