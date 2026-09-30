# TODO

- [x] Update to the latest stable Godot release: 4.7.2 stable, tested by the author. `project.godot` and `CLAUDE.md` now point at it.
- [x] Test with a dev build of Godot 4.8: 4.8-dev6 loads and runs the demo with no script errors, and the author confirmed it looks good. Re-test with dev7 or later once desktop binaries are published (4.8-dev7 had none on 2026-09-30).
- [x] Check the menu visually with keyboard, mouse and gamepad input: done by the author on 4.7.2 and 4.8-dev6. Gamepad back needed a `ui_cancel` binding (see the addon README).
- [ ] Consider configuring the cascade offset (`panel_offset` and the `panel_offset_x`/`panel_offset_y` theme constants) in units of line height, so it follows the font size. It is a fixed pixel value now. The demo uses 32×32 for Press Start 2P and the 16×16 default for the other fonts.
- [ ] Re-check the leaked-resource warning at exit on newer Godot versions. It comes from `@export var children: Array[RetroMenuItem]` in `retro_menu_item.gd`: an exported typed array of the script's own class keeps the script alive at shutdown (an exit-time warning only, seen on 4.7.2 and 4.8-dev6). Untyped or `Array[Resource]` exports do not leak. If we publish the addon, consider `@export var children: Array[Resource]` (looser typing, needs casts) to avoid the warning.
- [ ] Choose a test framework (GUT or gdUnit4) and a linter or formatter (gdtoolkit), then document the commands in `CLAUDE.md`.
- [ ] Consider a per-item `activated` signal (or an optional `Callable`) on `RetroMenuItem`, so simple menus can be wired without one big `item_activated` handler, for example `root.add_item("Attack", Action.ATTACK).activated.connect(attack)`. Deferred for now to avoid two ways of doing the same thing.
- [x] Add radio-button items: `RetroMenuItem.Type.RADIO`, `group` (int, siblings only), `add_radio()`, `select_radio()`, `get_selected_radio()`, drawn as `( )` and `(x)`, sharing the checkbox behavior and the `item_toggled` signal.
