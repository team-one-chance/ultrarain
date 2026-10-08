# Development menu

In a room with a player, press **F1** to open or close the menu. **Esc**, Left,
or Backspace goes back to categories, then closes from the category page.
Use Up/Down and Enter, or click a row. Gameplay and physics pause
while the menu is open; actions resume gameplay. F3 retains its existing coin
behavior.

- **F2** toggles collision drawing directly, including while moving.
- Collision drawing combines native physics fixtures with colored instance
  bounding boxes: cyan player, green terrain, red enemies, yellow attacks,
  gray other sprites. Physics fixtures use GameMaker's native debug colors.
  Sprite boxes are bounds, not exact outlines of precise sprite masks.
- Invincibility covers the shared damage method and instant-kill wire/spike
  hazards. Active debug toggles are shown after closing the menu and survive
  room restarts.
- Refill restores health and coins. Weapon actions select pistol or sword and
  reset their attack timers.
- Point the cursor at a world position **before opening F1**, then choose the
  cursor teleport action. Saved test positions and the room's initial player
  position are also available. Teleports clear velocity and damage recoil;
  they do not check whether the destination is inside a wall.
- Save position records the player's current position. The bookmark lasts
  until the room is restarted or changed. Restart room resets gameplay.

The category page groups controls into Player, World, Enemies, Time, and Debug.

Enemy controls spawn a grunt, drone, or miniboss at the cursor position captured
when F1 opens. Freeze enemy AI stops enemy Step logic, automatic path movement,
and animation while keeping enemies visible and damageable. Clear enemies also
removes drone bullets. Aim above the floor when spawning; positions are not
checked for walls.

Time controls provide 100%, 50%, and 25% speed, simulation pause (**F4**), and
one simulation frame (**F5**). F5 closes the menu if necessary, advances one
frame, and leaves the simulation paused. F4 toggles pause independently of the
menu. Selecting a speed keeps the menu open; close F1 to observe it. Speed
changes do not cancel simulation pause. Time controls reset on room changes.
Slow motion changes GameMaker's game speed while leaving instances active, so
movement, animation, alarms, and timers follow the slower update rate. Menu and
pause controls stay responsive at the normal update rate. Enemy AI freeze remains
active during single steps. If a collision toggle changes while paused, step once
to refresh its drawing.

The menu uses the larger antialiased console font with local text filtering;
world sprites retain their existing filtering.

Development configuration is at the top of `objects/o_DevMenu/Create_0.gml`.
Set `enabled = false` before shipping to disable menu input and drawing.

Runtime checks to perform in GameMaker:

1. Open/close F1 with keyboard and mouse; verify enemies and physics freeze
   and resume, and selecting a weapon does not fire it on the closing frame.
2. Toggle F2 while standing and sliding in both directions. Compare the
   actual physics fixture to the sprite bounding box; check terrain, enemies,
   projectiles, and sword slash boxes.
3. Enable invincibility and touch a lethal hazard; disable it and verify
   normal damage/death returns.
4. Equip each weapon, refill, save/restore a position, teleport to the cursor
   and spawn, and restart the room. Confirm F1 still works afterward.

5. Spawn each enemy type at the cursor, freeze/unfreeze AI while moving, damage
   a frozen enemy, and clear enemies. Confirm normal AI resumes after unfreezing.
6. Compare player and enemy motion at 100%, 50%, and 25%. Pause with F4,
   advance repeatedly with F5, and resume with F4. Open/close F1 while paused
   and verify the game remains paused until explicitly resumed.
