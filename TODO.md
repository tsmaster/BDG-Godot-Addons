# TODO

- [x] Update to the latest stable Godot release: 4.7.2 stable, tested by the author. `project.godot` and `CLAUDE.md` now point at it.
- [x] Test with a dev build of Godot 4.8: 4.8-dev6 loads and runs the demo with no script errors, and the author confirmed it looks good. Re-test with dev7 or later once desktop binaries are published (4.8-dev7 had none on 2026-09-30).
- [x] Check the menu visually with keyboard, mouse and gamepad input: done by the author on 4.7.2 and 4.8-dev6. Gamepad back needed a `ui_cancel` binding (see the addon README).
- [ ] Consider configuring the cascade offset (`panel_offset` and the `panel_offset_x`/`panel_offset_y` theme constants) in units of line height, so it follows the font size. It is a fixed pixel value now. The demo uses 32×32 for Press Start 2P and the 16×16 default for the other fonts.
- [ ] Re-check the leaked-resource warning at exit on newer Godot versions. It comes from `@export var children: Array[RetroMenuItem]` in `retro_menu_item.gd`: an exported typed array of the script's own class keeps the script alive at shutdown (an exit-time warning only, seen on 4.7.2 and 4.8-dev6). Untyped or `Array[Resource]` exports do not leak. If we publish the addon, consider `@export var children: Array[Resource]` (looser typing, needs casts) to avoid the warning.
- [x] Test framework: gdUnit4 v6.2.1 is installed, with suites in `test/` (see `CLAUDE.md` for the commands).
- [ ] Consider a per-item `activated` signal (or an optional `Callable`) on `RetroMenuItem`, so simple menus can be wired without one big `item_activated` handler, for example `root.add_item("Attack", Action.ATTACK).activated.connect(attack)`. Deferred for now to avoid two ways of doing the same thing.
- [x] Add radio-button items: `RetroMenuItem.Type.RADIO`, `group` (int, siblings only), `add_radio()`, `select_radio()`, `get_selected_radio()`, drawn as `( )` and `(x)`, sharing the checkbox behavior and the `item_toggled` signal.

- [x] Linter and formatter: gdtoolkit (`gdlint`, `gdformat`) with an 80-character limit; commands are in `CLAUDE.md`.
- [ ] Check gdUnit4 (or a newer release) against Godot 4.8 once it is stable, and re-run the suite on 4.8-dev builds.
- [ ] Consider a way to hold several child contexts at once. `replace_child()` manages a single slot; a context can hold more children by hand, and teardown already handles them, but there is no mounting helper for them.
- [ ] Consider letting `tear_down()` be awaitable (for exit transitions). Only `setup()` may await today.
- [ ] Test `bdg_context` under Godot 4.8-dev builds along with the rest.
