Falling robot grinder sequence in LE_TUTORIAL_WIP. There is no visible heap.

The upper red marker spans (4736,544) and (4736,576). Incoming robots spawn at random points across the grinder width (x=4416..5120)
and the marked upper band (y=544..608), with a 32-pixel edge margin. The lower red marker spans three tiles
at x=4800..4895, y=2464; its bottom edge meets the ground at y=2496.
The invisible o_RobotScrapEmitter remains on the RobotScrap layer. Room markers
and existing grinder placements are preserved.

Every 0.96-1.04 seconds, one or two metal hatches appear at random drop points.
This preserves the current one-second interval in the emitter. Each hatch opens
its sliding shutters over 0.09 seconds, then releases exactly one robot. The
robot is clipped at the opening while emerging, so it does not appear above
the door. Once its top clears the opening, the shutters close over 0.09 seconds
and the hatch fades away over 0.05 seconds. A typical hatch lasts about 0.53
seconds. Pending hatch drops count toward the 32-body cap. The hatch has no
collision mask; emerging robots retain their normal incoming damage behavior
below the opening.

Each body selects the grinder below its own spawn. Six mostly complete, damaged robot variants match
the six existing crushed variants. Both banks use 48x48 frames at 115-125%
scale, steel-blue/burgundy armor, black joints and unlit maroon eyes.

The incoming body falls to the nearest overhead grinder. Over 0.3 seconds it
shrinks, tumbles and fades into the gears, releasing nine short-lived steel
flecks at contact. Its matching crushed variant emerges beneath the gear and
preserves its horizontal velocity and falls along its original path to the
ground. Bodies are no longer steered toward one shared landing point. The removed heap's landing
profile is no longer used. Ground contact starts a 32-pixel sink over 0.42
seconds; fading begins only after the first 35% of that movement. A 12-second
expiry is a fallback. The objects remain non-solid, but incoming robots are
hazards: their sprite masks are swept in increments of at most 8 pixels to
avoid missed player hits during slow frames. A hit calls the player's existing
take_damage(10, source_x) routine, giving normal recoil/protection behavior,
and sets the same one-second dmg_cooldown as normal enemy bite/contact hits.
Each falling body can damage the player once. Its sprite_index and mask_index
are both cleared at grinder entry; separate drawing preserves its visible
animation. Grinding, outgoing scrap and sinking bodies have no collision mask
and cannot damage the player.

Incoming source artwork: incoming-robots-source.png.
Imported sprite bank: s_DamagedRobot-variants.png and sprites/s_DamagedRobot/.
Existing outgoing sprite bank: s_CrumpledRobot-variants.png.
The incoming artwork used the built-in image generation tool. Prompt:
"Create before-grinding versions of the same six robots in the same transparent
3x2 pixel-art sheet. Keep connected torsos, heads and most limbs, but add dents,
a missing or bent limb and exposed wires. Dead, limp wrecks, broad steel-blue
and burgundy armor, silver highlights, black joints, unlit maroon lenses; no
orange, eye glow, labels, shadows or scenery."
import-incoming.ps1 imports this source and registers the grinding Draw event.

Hatch artwork: hatch-parts-source.png, generated with the built-in imagegen tool.
Prompt: "GameMaker pixel-art metallic drop hatch parts sheet, two equal cells
side by side. LEFT: wide steel ceiling opening, straight-on 2D, rivets and a
dark central aperture, no panels. RIGHT: only closed symmetric sliding shutter
leaves joined at the center, no outer frame. Charcoal, cool blue-gray and silver,
chunky flat shades, true alpha; no orange, yellow, glow, text, shadows or robots."
import-hatch.ps1 imports the frame and shutter parts into two 96x32 frames in
sprites/s_RobotDropHatch/. The native atlas is s_RobotDropHatch-parts.png.
o_RobotDropHatch crops and slides the shutter halves inside the frame.

flow-preview.html is a self-contained animation with a full chute view,
grinder close-up, ground close-up and animated hatches. An optional "Show dangerous bodies"
overlay identifies incoming hazards; the preview does not simulate the player. Rebuild with build-flow-preview.ps1.
Logic checks ran the GML control flow with engine calls stubbed. They verified
10 damage through the shared player routine, recoil, one-second cooldown,
dash/slam protection, swept collision during a slow frame, actual mask removal,
harmless outgoing stages and preservation of falling direction at 30/60/144 FPS.
A 20-second emitter/hatch/body simulation at 30, 60 and 144 FPS verified one
release per fully open hatch, concealed initial bodies, clipped emergence,
closing only after the robot clears the lip, hatch cleanup and the 32-body cap.
It also verified that the current one-second interval remains intact. Damage
checks covered emerging robots, protection while dashing/slamming, and hidden
portions above the hatch. Sprite/event links, frame dimensions, alpha and
preview rendering were checked.
GameMaker runtime was not run here.

The earlier removed red mound/drop guide is retained in
removed-guide-tiles.json for reference; its heap artwork stays removed.
