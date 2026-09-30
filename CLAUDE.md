# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project status

MeatEngine is a new project with no code yet. This file records the stated intent; update it as the real structure, build commands and conventions appear.

Outstanding work is tracked in `TODO.md`. Add new tasks there, and tick or remove them when done.

## Purpose

A collection of reusable tools for games built with the Godot game engine.

- The tools are first for the author's own Godot projects. They may later be published to the Godot Asset Library.
- The initial features are written in GDScript. C# or C++ (GDExtension) may be added later where it is needed.

## Implications for how to write code here

- Since the tools may be published, keep each one self-contained and independent of any particular game. Do not hard-code project paths, autoload names or project settings. If a tool needs configuration, expose it through exported properties or a documented API.
- Asset Library submissions need a standard addon layout: `addons/<addon_name>/` with a `plugin.cfg`. Decide the addon boundaries before adding many tools, because they determine the layout.
- Stick to GDScript unless there is a concrete reason to leave it.
- Target Godot 4.7 (tested with 4.7.2 stable). Use 4.x GDScript syntax and APIs, and check the 4.7 docs rather than relying on memory of older versions.

## Planned layout (suggestion, not a commitment)

One repository and one Godot project (`project.godot`) hold several small, independent addons under `addons/`. Addon names use the `bdg_` prefix, not `meat_`. The prefix is not necessarily final.

```
addons/
  bdg_retro_menu/   # old-school menu (first feature, inspired by the OLC YouTube channel)
  ...               # possible later: scene management, behavior tree tools (Beehave), GOAP, MCTS
```

- Addons should not depend on each other unless essential. Any dependency on a third-party addon (for example Beehave) must be stated in that addon's docs.
- Keep algorithm code (GOAP, MCTS) in plain classes that do not depend on the scene tree, so it can be tested without a running game.

## bdg_retro_menu

Design is inspired by the retro menu by OneLoneCoder (OLC, javidx9): a cascading stack of grid panels. It uses Godot idioms and is not a port. Keep the credit to OneLoneCoder, with both links, in the docs (see `addons/bdg_retro_menu/README.md`):

- Video: <https://youtu.be/jde1Jq5dF0E>
- Source: <https://github.com/OneLoneCoder/Javidx9/blob/master/PixelGameEngine/SmallerProjects/OneLoneCoder_PGE_RetroMenu.cpp>

- `RetroMenuItem` (`Resource`) is the data tree. Game code identifies items by `id` (an int, meant to hold a game-defined enum member) and can attach any value in `metadata`. `type` is `ACTION`, `CHECKBOX` or `RADIO`. Both keep their state in `checked`, are drawn as text (`[ ]` / `[x]` and `( )` / `(x)`), and emit `item_toggled` without closing the menu. Radios are exclusive within the same `group` (an int) among siblings; use `select_radio()` on the parent to change the selection. An item with children is a submenu, and its `columns` and `max_visible_rows` set the panel layout.
- `RetroMenu` (`Control`) holds the panel stack, draws everything in `_draw()`, and emits `item_activated`, `cursor_moved` and `closed`.
- `RetroMenu._gui_input` marks events handled through a viewport reference taken before it acts, because a listener may remove the menu from the tree (mounting another screen), and `accept_event()` does nothing once a node is outside the tree. Without this the same keypress also reached the new screen.
- Input: the built-in `ui_*` actions (keyboard and gamepad) plus mouse hover, click, right-click for back, and wheel scroll. The addon defines no input actions of its own.
- Styling comes from the theme type `RetroMenu` (`panel` and `cursor` styleboxes, `font`, `font_size`, colors, and the `item_padding` constant). The fallback panel texture is generated in code, so the addon ships no binary assets. User-supplied textures and fonts should go through a Theme.
- Decision: the addon uses Godot's built-in fallback font by default and bundles no fonts, because that is lightweight and easy. Demo key 1 shows this default.
- Font candidates and pixel-font setup notes are in `docs/retro_fonts.md`. The demo includes Press Start 2P and Silkscreen (SIL OFL), Kenney Pixel (CC0), and Kreative Software's Print Char 21 and PR Number 3 (a restrictive free-use license: no modification, no sale, credit required) and Hack (MIT / Bitstream Vera, a smooth font) under `demo/fonts/`, each with its license file. Keep fonts out of `addons/` unless their license permits shipping them with the addon.
- `demo/` holds a runnable demo scene that is the project's main scene. It is outside `addons/` so it is not shipped with the addon.

## bdg_context

Scoped contexts, based on Hovering Skull's pattern (<https://youtu.be/HkjOE4FbrXo>; credit belongs in the docs). Design decisions are in `docs/context_design.md` and the author's notes are in `docs/godot_context_notes.md`.

- `Context` (`Node`) has virtual `build()`, `setup()` (may `await`) and `tear_down()`, a `state`, and helpers `start()`, `replace_child(ctx, bind)`, `unmount_child()` and `get_child_context()`.
- `bind_dependencies()` is deliberately not declared on `Context`. Each subclass declares its own typed version, because GDScript rejects an override with a different signature. The parent calls it from the `bind` callable passed to `replace_child()`.
- No service registry and no automatic injection: the parent passes dependencies explicitly.
- `replace_child()` refuses an overlapping mount (logs an error, returns `false`) and returns `false` if the child was torn down during `setup()`. Tests for refusals use gdUnit4's `assert_error(...).is_push_error(...)`.
- Demo: `demo/context/` (run with `res://demo/context/context_demo.tscn`). `DemoRoot` mounts `DemoSplash` (its `setup()` awaits a fake load), then `DemoMainMenu`, then a mode or settings screen. Tests in `test/test_context.gd` and `test/test_demo_context.gd`.

## Commands

The Godot binary is not on `PATH`. The author's copy is `../GodotEngine/4.7/Godot_v4.7.2-stable_linux.x86_64`, relative to the project root (Godot 4.7.2 stable).

```
G=../GodotEngine/4.7/Godot_v4.7.2-stable_linux.x86_64
$G --headless --path . --import            # required once on a fresh checkout, to register class_name globals
$G --headless --path . --quit-after 120    # load and run the demo headless; script errors go to stderr
$G --path .                                # run the demo (a gray window means a script error, so check the console)
$G --editor --path .                       # open the editor
```

Without the `--import` pass, a fresh checkout fails with `Could not find type "RetroMenu"`, because `.godot/` (which holds the global class cache) does not exist yet. Headless mode has no renderer, so it cannot show whether drawing is correct.

Also tested with 4.8-dev6 at `../GodotEngine/4.8/Godot_v4.8-dev6_linux.x86_64`. Run the commands above with that binary in place of `$G`.

### Tests

Tests use gdUnit4 v6.2.1 (MIT, `addons/gdUnit4/`, the repo moved to `godot-gdunit-labs/gdUnit4`), and suites live in `test/`. Each suite extends `GdUnitTestSuite`. Menu tests send `ui_*` actions to the menu with `get_viewport().push_input()`.

```
export GODOT_BIN=../GodotEngine/4.7/Godot_v4.7.2-stable_linux.x86_64   # run once per shell
bash addons/gdUnit4/runtest.sh -a res://test                           # all suites
bash addons/gdUnit4/runtest.sh -a res://test/test_retro_menu.gd        # one suite
bash addons/gdUnit4/runtest.sh -a res://test -i res://test/test_retro_menu.gd:test_name   # skip one test or suite (-i means ignore)
```

The command line can run one suite, but as far as I found it has no option to run a single test. Use `-i` to skip tests instead, or run a single test from the editor's gdUnit4 panel.

Do the `--import` step above first on a fresh checkout. Exit code 0 means every test passed, and 100 means failures. Reports are written to `reports/`, which is git-ignored. `.gitattributes` marks `addons/gdUnit4` and `test/` as `export-ignore`, so they stay out of `git archive` downloads. gdUnit4 v6.2.1 lists support for Godot 4.5 to 4.7.1, and it has not been checked against 4.7.2 (it worked here) or 4.8.

### Lint and format

gdtoolkit (`gdlint` and `gdformat`, version 4.5.0 tested) checks our scripts. It is a Python tool that is not vendored: install it with `pipx install gdtoolkit`. Run both from the project root on our own folders only, because `gdlint .` would also lint the vendored `addons/gdUnit4`:

```
gdformat --line-length 80 addons/bdg_context addons/bdg_retro_menu demo test   # add --check to only report
gdlint addons/bdg_context addons/bdg_retro_menu demo test                      # settings are in gdlintrc
```

The line limit is 80 characters. It is set in `gdlintrc` (`max-line-length`) and, separately, by the `--line-length 80` option to `gdformat`, so keep the two in step. `gdformat` does not wrap comments, so long comment lines have to be wrapped by hand. The test suite disables `max-public-methods` with a `# gdlint: disable=max-public-methods` comment on its first line.

## Architecture

To be filled in when the code exists.
