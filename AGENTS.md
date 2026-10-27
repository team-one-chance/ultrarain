# Repository Guidelines

## Project Structure & Module Organization

ULTRARAIN is a GameMaker 2D sidescroller. Open `ULTRA RAIN.yyp` as the project entry point. Gameplay objects and their event files live in `objects/`; reusable GML functions are in `scripts/`. Rooms are in `rooms/`, shaders in `shaders/`, and visual and audio assets in `sprites/`, `tilesets/`, `sounds/`, and `fonts/`. Project configuration lives in `options/`; `docs/` contains development notes and asset tooling. `LE_MENU` is the starting room, and `TESTING` is a development room.

## Build, Test, and Development

- Open `ULTRA RAIN.yyp` in GameMaker and use the IDE's Run command to compile and launch the game. The README identifies IDE 2026.0.0.16 as the saved version.
- Use the GameMaker Windows target to compile changes before submitting them. If invoking Igor directly, use `Windows Compile` or `Windows Run` with the appropriate local runtime and project options.
- Run `git diff --check` to catch whitespace errors before committing.
- In game, F1 opens the development menu; F2 toggles collision display. See `docs/dev-menu.md` for controls and limitations.

## Coding Style & Resources

Follow the surrounding GML style: generally four-space indentation, braces on separate lines for functions and blocks, and descriptive names. Existing object and sprite names commonly use `o_` and `s_` prefixes; local variables often use a leading underscore. Keep object events in their existing `Create_0.gml`, `Step_0.gml`, and `Draw_0.gml` files. Preserve GameMaker's `.yy` and `.yyp` resource formatting and include associated metadata when adding or changing resources. `.gitattributes` specifies LF endings for GML and project metadata.

## Testing Guidelines

No repository-wide automated test framework or coverage target is documented. Compile, then exercise the affected behavior in the runner, including relevant room transitions and failure cases. For visual changes, inspect the effect in game; compilation alone cannot establish appearance. Record manual checks and any untested cases in the pull request.

## Commits & Pull Requests

Recent commits generally use short, informal, action-oriented subjects, such as `add parry effect and parry grace to scout`. Keep changes focused and describe their behavior. Pull requests should explain the problem and change, link relevant issues, list validation performed, and include screenshots or video for visible changes.
