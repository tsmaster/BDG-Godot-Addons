# TODO

- [ ] Update to the latest stable Godot release. The current binary is 4.7-dev1, which is a development build, so confirm what "latest stable" is, update `config/features` in `project.godot`, and update the target version in `CLAUDE.md`.
- [ ] Test with a dev build of Godot 4.8. Check that the demo loads and runs, and note any API breakage.
- [ ] Run the demo with rendering and check the menu visually with keyboard, mouse and gamepad input. It has only been loaded headless so far.
- [ ] Pick a default font for the addon from the demo comparison (keys 1-4), and decide whether to bundle it under `addons/bdg_retro_menu/`, together with its license file.
- [ ] Consider configuring the cascade offset (`panel_offset` and the `panel_offset_x`/`panel_offset_y` theme constants) in units of line height, so it follows the font size. It is a fixed pixel value now. The demo uses 32×32 for Press Start 2P and the 16×16 default for the other fonts.
- [ ] Investigate the leaked-resource warning at exit (possibly the generated fallback panel texture).
- [ ] Choose a test framework (GUT or gdUnit4) and a linter or formatter (gdtoolkit), then document the commands in `CLAUDE.md`.
