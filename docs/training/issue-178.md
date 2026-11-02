# Tutorial fixes for issue #178

Source: <https://github.com/team-one-chance/ultrarain/issues/178>.

All fourteen items are addressed locally. Authored notes, tile data, and existing
colliders are retained. Added collision faces, player barriers, and the hold gate
are section-owned runtime instances, removed and rebuilt on transitions/retries.
The pre-existing local background-layer visibility edit is preserved.

| Item | Change | Verification |
| --- | --- | --- |
| 1. Text size | Enlarged objective text and input icons/labels, scaled to GUI resolution. Text wraps inside a panel that clears the health HUD. | Screenshots; scale checks; player remains below the panel at the materials ceiling. |
| 2. Abyss left edge | A player-only wall continues downward from the drop's left edge, retaining the authored teleport span. | Actual leftward movement cannot drift outside the abyss trigger. |
| 3. Dash + jump prompts | Separate remappable jump/air-dash and ground-dash/jump prompts at the two gaps. Context reminders remain even after the action was demonstrated earlier. | Both binding arrays and both positional cues verified with objectives already satisfied. |
| 4. Dash teleporter | Uses the player's leading collision edge. Teleport clears the sliding fixture, dash/slide momentum, and transient locks; synchronizes draw and physics positions; and snaps/follows the physical destination. | Actual sliding-footprint entry advances once; standing fixture, destination, and camera verified. |
| 5. Transfer visuals | Animated holographic transfer volumes mark the abyss, dash exit, and later automatic exits. | Marker check and screenshot. |
| 6. Wall-hold skip | Requires 0.35 continuous simulation seconds of actual near-stationary wall hold while pressing toward the wall. A visible temporary gate catches a straight fall and opens only after the hold. | Falling, brief contact, sustained holding, gate release, and retry checked using movement input. |
| 7. Invisible breakables | Five breakables now live on the foreground instance layer with a dedicated cyan X-marked draw event. Ordinary breakable rendering remains unchanged outside training. | Layer/depth assertions and floor screenshot. |
| 8. Pillar collider | Added the missing right face and top cap of the existing painted wall-hold pillar. Existing red faces remain intact. | Collider query, actual leftward movement into the right face, and reset ownership checks. |
| 9. Slam prompt | Wall-hold entrance teaches wall holding. Slam instruction appears near the authored `bp slam` marker and breakable floor, after the wall hold, rather than in the descent shaft. | Entrance, shaft, and floor positions tested; floor screenshot. |
| 10. Targets / cheesing | Pistol arena has player-only side barriers that allow bullets through. Sword arena has side/roof barriers. The first sword dummy still requires real sword strikes; follow-up targets accept either weapon, including the far target. | Actual pistol fire clears all four pistol targets from the arena. Actual sword strikes unlock the follow-up pair, then real pistol shots clear both. Player movement cannot leave the pistol firing area. |
| 11. Materials escape | A player-only roof caps the existing side walls. A tutorial-only camera limit hides the neighboring course while preserving headroom beneath the enlarged HUD. | Upward physics blocked; camera framing and normal-room isolation checked. |
| 12. Parry crash | Removed the unused assignment reading undefined `sword_combat_facing_duration`. Sword parry becomes available with the sword, independently of the later pistol-coin unlock. | Actual parry input before the first sword strike and beside a materials dummy; no runtime error. |
| 13. Pistol before coins | Coin exercise first shows an equip-pistol binding prompt and waits for actual selection. It then teaches throwing and shooting; changing back to sword restores the pistol reminder without losing progress. Coin HUD follows the actual coin unlock, rather than sword-parry availability. | Equip gate, accepted selection, real coin throws/shots, and subsequent ricochet exercise tested. |
| 14. Chain spoiler | Removed chain-hit wording from player-facing instructions and progress text. Direct hits are still the objective internally. | Both instruction phases checked; coin shooting and ricochet progression remain functional. |

The initial pistol-area bug report did not reproduce with actual pistol input:
all four targets could be destroyed from spawn even before these fixes. The far
**sword-area follow-up** did reject pistol damage because the old tutorial-only
restriction covered every sword target. That restriction now applies only to the
first melee teaching dummy, with a clear wrong-weapon instruction.

## Validation

- Windows and Linux VM compilation with runtime 2026.0.0.23.
- Focused runner regression covers the items above using real movement, parry,
  sword, pistol, equip, and coin inputs. It also verifies retry ownership and
  normal-game equipment/camera isolation.
- The harness positions the player at selected obstacles and freezes thrown coins
  for deterministic aim. It verifies those mechanics and transitions; it is not
  a continuous unassisted traversal of every platforming corridor.
- `git diff --check`; authored note and room-resource preservation reviewed.

Current results: [runner output](issue-178-results.txt).
The disposable controller's Step event is [issue-178-regression.gml](issue-178-regression.gml).
Use the persistent test-controller setup described in
[the simulation implementation notes](../training-simulation.md#validation).
The original lifecycle/mechanics result files document the initial implementation;
this issue's runner output records the current fixes.

Screenshots: [breakable floor and larger instructions](issue-178-floor.png),
[transfer marker](issue-178-transfer.png),
[materials framing](issue-178-materials.png),
[coin instruction and bindings](issue-178-coins.png).
