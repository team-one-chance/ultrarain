# Development menu

Press **F1** to open or close the menu. Use **Up/Down + Enter**, or click a row.
**Esc**, **Left**, or **Backspace** returns to the categories; from the category
page, it closes the menu.

Opening the menu pauses gameplay and physics. Closing it resumes gameplay unless
simulation pause is still enabled. Toggle actions and speed selection keep the
menu open; refill, weapon selection, teleports, saving a test position, enemy
spawns, and clearing enemies close it after applying the action.

## Shortcuts

| Key | Action |
| --- | --- |
| **F1** | Open or close the development menu |
| **F2** | Toggle collision drawing |
| **F4** | Pause or resume the simulation |
| **F5** | Advance one simulation frame and remain paused |
| **F6** | Toggle freecam; close the menu and clear simulation pause |
| **WASD** in freecam | Move the camera |
| **Shift** in freecam | Move the camera faster |

F2, F4, F5, and F6 also work without opening the menu. **F3** retains the
player's existing coin behaviour; it is not a menu action.

## Player

- **Invincibility:** toggles the shared player damage protection, including
  instant-kill hazards that use that protection.
- **Refill health and coins:** restores health and coin stock to their current
  maximums. It does not replenish healing syringes.
- **Equip pistol / reset cooldown** and **Equip sword / reset cooldown:** select
  the weapon, update the arm rig, and reset the weapon fire and sword swing state.

Invincibility and collision drawing survive ordinary room restarts and room
changes. Active debug states are shown in the HUD after closing the menu.

## World / teleport

Point the cursor at a world position **before opening F1**. The menu captures
that position when it opens and uses it for cursor teleports and enemy spawns.

| Action | Behaviour |
| --- | --- |
| Teleport to cursor | Move the player to the captured world position |
| Save current test position | Bookmark the player's current position |
| Teleport to saved position | Restore the bookmark; does nothing if none is saved |
| Teleport to room spawn | Return to the first player position recorded by this menu controller in the room |
| Restart room | Restart gameplay in the current room and reset time controls |

Teleports clear player velocity, damage recoil, and the active slam. They do not
check whether the destination is inside a wall. The saved test position and room
spawn record belong to the current menu controller and are lost when it is
recreated, including on an ordinary room restart or room change.

## Enemies

Spawn a **grunt**, **drone**, or **miniboss** at the cursor position captured
when F1 opened. Aim above the floor; spawn positions are not checked for walls.
Chip robots do not currently have a dedicated spawn action.

**Freeze enemy AI** stops the supported enemy Step logic, automatic path
movement, and animation while keeping enemies visible and damageable.
**Clear all enemies** destroys instances of `oEnemyParent` and its descendants,
and removes drone bullets.

The AI freeze toggle keeps the menu open. Spawning or clearing enemies closes
it. AI freeze also remains active during single-frame simulation steps.

## Time

**F4** toggles simulation pause independently of the menu. Closing F1 does not
cancel an existing simulation pause.

**F5** closes the menu if necessary, advances one simulation frame, and leaves
the simulation paused. Press F4 to resume normal simulation.

The menu offers **100%**, **50%**, and **25%** speed settings, but all three
entries are currently labelled **BROKEN** in the source. Treat them as
experimental controls, not reliable slow motion. Their implementation changes
GameMaker's game speed; selecting one keeps the menu open and does not cancel
simulation pause.

Time controls reset when the menu controller is recreated. F6 clears simulation
pause but does not reset the selected speed.

## Debug / collisions

### Collision overlay

F2 combines GameMaker's native physics fixture drawing with coloured instance
bounding boxes:

| Colour | Bounding box |
| --- | --- |
| Cyan | Player |
| Green | Objects whose names contain `Block`, `Door`, or `Chute` |
| Red | `oEnemyParent` and its descendants |
| Yellow | Objects whose names contain `Bullet`, `Slash`, `Beam`, or `Trap` |
| Grey | Other instances with a sprite or collision mask |

Physics fixtures use GameMaker's native debug colours. Bounding boxes are not
exact outlines of precise sprite masks; the name-based colours are a visual aid,
not a complete classification of collision behaviour.

While paused, the screen uses the last rendered simulation image. After changing
the overlay while paused, advance one frame with F5 to refresh its drawing.

### Freecam

Toggle freecam with **F6** or the action under **Debug / collisions**. Move with
**WASD** and hold **Shift** for faster movement. Default speeds are **650** and
**2200** world pixels per second.

Freecam takes priority over player following, train framing, and seamless-gate
framing. Normal player Step controls are suspended and player velocity is set
to zero. The rest of the world continues simulating unless separately paused;
freecam itself does not freeze enemies or hazards.

During freecam rendering, layers whose names start with `dark_` or contain
`black` are temporarily hidden. Their visibility is restored after rendering,
preserving the underlying reveal-trigger state. This does not disable every
lighting effect.

Toggling freecam closes the menu and clears simulation pause. If F4 is used
afterwards, the camera also stops updating until the simulation resumes or is
stepped. Freecam is disabled at room end.

## Configuration

Configuration is at the top of
[`objects/o_DevMenu/Create_0.gml`](../objects/o_DevMenu/Create_0.gml):
`enabled`, `menu_key`, `collision_key`, `row_height`, `panel_width`, and
`menu_scale`. Freecam speed settings are near the bottom of the same event.

Set `enabled = false` for a release build to disable menu input and debug
drawing. The controller also clears invincibility and collision drawing when
created with development mode disabled.

The menu scales its panel and mouse targets to the GUI size. It uses the console
font with local texture filtering; the previous drawing state is restored
afterwards.

## Runtime checks

These are manual checks to perform in GameMaker, not recorded test results.

1. Open and close F1 with keyboard and mouse. Confirm gameplay and physics pause
   and resume, and selecting a weapon does not fire it on the closing frame.
2. Toggle F2 while standing and sliding in both directions. Compare the physics
   fixture with the sprite bounding box. While paused, use F5 to refresh it.
3. Toggle invincibility and check ordinary damage and lethal hazards. Refill
   health and coins, and confirm syringes are unchanged.
4. Equip each weapon, save and restore a position, teleport to the captured cursor
   and room spawn, and restart the room. Confirm F1 still works afterwards.
5. Spawn each supported enemy type, freeze and unfreeze AI, damage a frozen
   enemy, and clear enemies. Confirm normal AI resumes after unfreezing.
6. Pause with F4, step repeatedly with F5, and resume with F4. Open and close F1
   while paused and confirm that simulation pause remains enabled. Investigate
   speed controls separately; their current BROKEN labels remain applicable.
7. Toggle F6 from gameplay and from the menu. Check WASD movement, Shift speed,
   suspended player controls, and continued world simulation. Confirm dark
   layers return after disabling freecam and camera following resumes.
8. Restart or change rooms. Confirm temporary positions, time controls, AI
   freeze, and freecam reset, while invincibility and collision drawing retain
   their toggled states.
