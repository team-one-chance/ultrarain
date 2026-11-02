# Optional training simulation

`LE_MENU` is first in the project room order. TRAINING SIMULATION launches a fresh
`r_preTutorial`; Start retains the existing difficulty selection and normal launch.
The training controller, equipment ownership, objectives, and ability gates are
room/instance state. Completion and pause-menu exit clear normal-run globals and
restart into the menu. The simulation is always replayable.

## Authored sequence

All 51 `o_Notes` overrides in `r_preTutorial` were read before implementation.
The authored notes, tile layout, existing colliders, and creation order are preserved.
Section-owned runtime collision additions are documented in the issue #178 follow-up.
Spawn markers use their 32-pixel editor cell: player feet are at `(x + 16, y + 32)`.

| Section | Authored notes and implementation |
| --- | --- |
| 1. Look | `spawn look`: fixed 150 HP, no weapons, movement locked. All six `looktarget` and two `target` nodes respond to actual crosshair alignment. Every node must be acquired. |
| 2. Jump | `spawn jump` unlocks movement. Jump must execute. `dead end` and `abyss tp` define the physical hole and its landing trigger range. Falling into that range teleports to `spawn slide`, as the abyss note specifies. |
| 3. Slide / dash | `bp slide`, `low hanging ceiling`, `bp jumpdash`, and `bp dash` provide contextual prompts. Actual sliding movement, an accepted air dash, and an accepted ground dash are required before `end of slide and dash` advances. |
| 4. Wall hold / slam | `spawn wallhold`; the existing red `o_Block_scary` walls already satisfy `ouch wall`. A sustained actual wall hold must occur; a temporary gate prevents falling past this objective. `bp slam` leads to five 32-pixel breakables in `breakablefloor`. A slam through the floor followed by physical descent to `get pistol` unlocks the pistol. There is no teleport between this floor and the pistol area. |
| 5. Pistol | `get pistol` unlocks only the pistol. Three `enemy spawn 1` stationary targets plus one vertically moving `enemy spawn 2` target materialize. Targets ignore slam damage so the arrival slam cannot consume this shooting exercise. `up next sword` advances only when all four die. |
| 6. Sword | `spawn sword` grants the sword while keeping the pistol selected. Switching to the sword spawns `enemy spawn 3`. Its death spawns both `enemy spawn 4` targets. The first dummy requires real sword strikes; the follow-up pair accepts either weapon. All three must die before `up next materials`. |
| 7. Materials | `spawn materials` grants nothing. `mat dummy 1`, `mat dummy 2`, and `mat dummy 3` select three successive targets at `enemy spawn 6`: ordinary, armored, then an unarmored body behind a separate player-facing floating shield plate. `up next coins` advances after the third body dies. Shared shield damage multipliers are pistol ×0.1 and sword ×5. |
| 8. Coins | `spawn coins` first teaches and requires pistol selection, then unlocks the coin demonstration and replenishes its coins. `info about coins tut` / `up next coins2`: three direct, airborne, player-owned coin hits from the initial pistol trace are required. Subsequent ricochets never increment this objective. |
| 9. Ricochet | `spawn coins2` locks movement but permits aiming/shooting. `info about coin tut` requires a coin shot over the existing wall to reach `enemy spawn 5`. Existing coin wall penetration/targeting remains in use. Its death satisfies `up next combat`. |
| 10. Combat / exit | `spawn combat` restores the normal four-coin pool and recharge. After one simulation second, `enemy spawn 7` produces an easy cyan scout; its actual death produces the cyan drone at `enemy spawn 8`. After the drone dies, the breathing radial `terminal lucidity` glyph appears. Interacting starts the top-right error flood from `interacting with terminal lucidity`, then returns to the menu. |

The `up next` and `info` markers describe conditions rather than extra physical
interaction requirements. The three `mat dummy` markers select variants, not
three simultaneous spawn locations. The final combat notes explicitly require
scout death followed by drone death; they specify no additional action checklist.
No design note was inaccessible. No unrelated boss appears in the simulation.

## Implementation

- `scr_training_simulation` contains section initialization, action availability,
  target registration, objective updates, generation tokens, and reset/exit logic.
  Only the scout's authored one-second spawn delay and terminal presentation use
  timers for progression. Timers cannot complete a player-action objective.
- `o_TrainingSimulation` owns the current section, staged encounters, all temporary
  actors, holographic instructions, transitions, and terminal presentation.
- `o_TrainingTarget` is classified as a combat target through `oEnemyParent`, but
  supplies its own damage/draw/lifecycle events and allocates no navigation grid.
  Production hitscan, sword, coin and slam paths discover it normally. The separate
  floating plate blocks actual shot traces; its body is independently damageable.
- `shield_material_settings()` documents the multipliers shared by the training
  materials and production shield. Production values and balance are unchanged.
- Accepted movement actions emit events from the existing player implementation.
  Input gates reuse remappable controls, including the arrow-key alternatives.
- Every section can be re-entered with `controller.enter(section)`. A retry clears
  actors, coins, slashes, beams, drone bullets, hit trails, and simulation effects;
  reconstructs the player; restores the section's equipment and floor; and snaps
  the camera. A generation token prevents old death callbacks from advancing a
  new encounter. Unexpected actor removal requests a retry rather than a kill.
- Pause → Restart from Checkpoint retries the current section. Restart Level
  restarts the simulation. Exit to Main Menu uses the existing clean restart.

## Weapon ownership

The player owns explicit `owns_pistol` and `owns_sword` flags. `weapon_validate()`
selects an owned weapon or `"none"` and cancels stale sword/parry state. Selection,
attacks, secondary input, relaxed unarmed arm pose, reticle, and HUD obey the
selection/ownership. Ownership transfers with seamless player state. Ordinary
player creation still grants both weapons; tutorial flags are never saved.

## Presentation and placeholders

Targets use the existing `sHeal` resource only as a replaceable collision mask;
its artwork is not drawn. Their cyan geometric shapes, scanlines, shield outlines,
spawn materialization, and digital breakup are code-drawn placeholders. Final
scout/drone use the production sprites and AI with cyan tint, brief materialization,
and digital death instead of wreckage. Finished cyberspace art can replace these
renderers without changing objectives or damage behavior. The radial exit glyph
is also code drawn. Existing UI sounds accompany new instructions. Teleports use
0.13 seconds of nonblocking scanline flicker and an immediate camera snap.

## Developer inspection

Outside exhibition lock, F4 toggles the training overlay. It reports section,
stage, objective, demonstrated actions, direct coin progress, owned/selected
weapons, ability gates, remaining targets, generation, reset, transition, and exit
state. F1/F2 retain their existing developer behavior. The controller's `enter`
method permits isolated section setup in the GameMaker debugger; no debug command
is necessary for normal play.

## Validation

- Windows VM target: compiled successfully with runtime 2026.0.0.23.
- Linux VM target: compiled successfully with the same runtime. The MCP test
  wrapper failed during packaging with an empty destination name; explicit Igor
  output paths worked. The Linux runner launched with the installed Steam
  runtime's two legacy OpenSSL libraries preloaded (without its old libc).
- Lifecycle runner checks: menu placement and launch, all 51 notes recovered,
  unarmed start, fixed HP, no idle advancement, actual crosshair targeting,
  section initialization, staged enemy deaths, material multipliers, separate
  floating plate, death retry, all four ownership states, combat order, actual
  terminal interaction, error sequence, menu return, cleared run globals, replay,
  and default equipment/abilities in normal gameplay passed.
- Mechanics runner checks: actual slide through the low ceiling, jump, air dash,
  ground dash, end-of-section gating, wall hold, slam through all five floor
  segments, physical descent to the pistol area, survival of all pistol targets
  after the arrival slam, three direct pistol-to-coin hits, and repeated real
  coin ricochets to the target behind the wall passed.
- Tests used disposable project copies with a persistent test controller. The
  mechanics harness positions the player at selected obstacles and temporarily
  freezes thrown coins to make aiming deterministic; it still drives the real
  input, movement, raycast, ricochet, damage, and progression code. These checks
  establish the individual mechanics and transitions, not a continuous human
  playthrough of every platforming route. That full normal-pace playthrough is
  still required, particularly the long jump/dash gaps and wall descent.
- All authored player spawn cells were checked against collider rectangles:
  none intersects a solid. New project resources are registered in the IDE's
  ordering. `git diff --check` passes. The authored room geometry and all 51 notes remain intact; a pre-existing local layer visibility edit is preserved.
- Existing project diagnostics remain: unregistered `sprites/sAriIdle.new` and
  root-level `oLavaMolten`; normal-game runner output also reports existing tile
  index warnings from `o_SecretBackgroundPreview`. These were left outside scope.

Review artifacts: [unarmed start](training/look.png),
[floating shield](training/shield.png), [terminal errors](training/terminal.png),
[lifecycle results](training/lifecycle-results.txt), and
[mechanics results](training/mechanics-results.txt).

The two `*-harness.gml` files are the temporary test controller's Step bodies,
retained for reproduction. Its Create event initializes
`global.training_check_frame = 0` only if absent and defines
`check = function(condition, message) { show_debug_message((condition ?
"[TEST] PASS " : "[TEST] FAIL ") + message); };`. Make that controller persistent
and create it in the menu room in a disposable copy. The frame counter deliberately
survives game restarts so menu launch, completion, and replay can be verified.
Do not register these harnesses in the shipping project.

## Issue #178 follow-up

See [the itemized fixes and regression report](training/issue-178.md) for the
larger text, compound prompts, transfer markers, teleport/camera corrections,
wall-hold gate, runtime collision additions, visible breakables, corrected target
weapon rules, parry crash fix, and pistol-first coin instruction.
