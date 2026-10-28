# Breaker slam visual settings

Edit `scripts/scr_breaker_slam_visuals/scr_breaker_slam_visuals.gml` in GameMaker under **Scripts → scr_breaker_slam_visuals**. This is the single configuration for Breaker's slam in TESTING and every gameplay level.

Stop the current game, save the script, and run again after editing the source. Changing source code does not update the defaults of an already running game.

| Setting | Meaning |
| --- | --- |
| `radius_pixels` | Spread on each side of the impact. 32 pixels is one block. There is no additional 64-pixel cap. |
| `duration_seconds` | Total animation lifetime. Ribbons, dust, and the contact flash all scale with it. |
| `wind_colour` | Main wind color. This also colors the thin ground streaks. |
| `shade_colour` | Inner ribbon edge and pale dust color. |
| `flash_colour` | Contact-flash color. |
| `opacity` | Visibility of the whole effect, from 0 to 1. |
| `wind_height_pixels` | Height of the curling gusts. |
| `wind_width_pixels` | Ribbon thickness. |
| `wind_layers` | Number of staggered ribbons per side. |
| `layer_delay_fraction` | Delay between ribbons relative to the total duration. |
| `dust_count`, `dust_size_pixels`, `dust_opacity` | Dust amount, size, and visibility. |
| `flash_duration_fraction` | Fraction of the animation occupied by the flash; zero disables it. |
| `flash_radius_pixels`, `flash_height_pixels` | Flash width on each side and its vertical height. |

For example, `radius_pixels: 96` spreads three blocks per side. `duration_seconds: 0.56` makes the entire animation run twice as slowly as the default.

Every `oBreakerSlamVFX` instance references `global.breaker_slam_visuals`. The script initializes that struct only once per game, so runtime changes survive room transitions. New rooms only need the normal Breaker object; they must not initialize or override these visual settings.

The player's slam uses `oSlamVFX` and has separate settings. Breaker's visual radius does not change his damage range, which is still controlled by his combat settings.

The boss effect draws after ambient lighting when a renderer is active. Otherwise it draws directly, including in TESTING, freecam, or rooms without lighting. It does not depend on bloom.

The GameMaker rendering and room-transition regression can be run with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/breaker-slam/run.ps1`. It compiles the real configuration and effect, checks GPU-rendered color and spread, changes rooms, and verifies duration and renderer fallback behavior. Generated files stay under the ignored `Build` directory. Runtime and user-profile paths can be supplied through the script's parameters.
