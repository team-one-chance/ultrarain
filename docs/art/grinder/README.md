The tutorial grinder row spans x=4384..5152 (768 pixels / 24 tiles).
It uses ten 96x96 sprites at a center spacing of 224/3 pixels, alternating
left and right. The sprites overlap by 21 1/3 pixels so the teeth engage.
The row retains its original center height of y=864 (sprite top y=816).

Each gear has eight involute teeth, a 20-degree pressure angle and a small
backlash. The right animation starts 22.5 degrees ahead of the left animation.
Both animations have 72 frames at 24 fps, giving one turn every three seconds.
The objects share an animation clock updated once in Begin Step and read in
Step; this also follows the project's dev_delta_time setting.

To place another horizontal row, alternate o_GrinderLeft / o_GrinderRight,
use 74.6666667-pixel spacing at scale 1, and leave instance rotation at zero.
Equal-size gears must have equal speed and opposite directions. The phase is
already built into the sprites.

Rebuild each sprite with build-animation.ps1 using -SpriteName s_GrinderLeft
-Direction -1, or -SpriteName s_GrinderRight -Direction 1. The generator reuses
the approved artwork as a material on mathematically defined tooth silhouettes.
