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

- `RetroMenuItem` (`Resource`) is the data tree. An item with children is a submenu, and its `columns` and `max_visible_rows` set the panel layout.
- `RetroMenu` (`Control`) holds the panel stack, draws everything in `_draw()`, and emits `item_activated`, `cursor_moved` and `closed`.
- Input: the built-in `ui_*` actions (keyboard and gamepad) plus mouse hover, click, right-click for back, and wheel scroll. The addon defines no input actions of its own.
- Styling comes from the theme type `RetroMenu` (`panel` and `cursor` styleboxes, `font`, `font_size`, colors, and the `item_padding` constant). The fallback panel texture is generated in code, so the addon ships no binary assets. User-supplied textures and fonts should go through a Theme.
- Font candidates and pixel-font setup notes are in `docs/retro_fonts.md`. The demo includes Press Start 2P and Silkscreen (SIL OFL), Kenney Pixel (CC0), and Kreative Software's Print Char 21 and PR Number 3 (a restrictive free-use license: no modification, no sale, credit required) and Hack (MIT / Bitstream Vera, a smooth font) under `demo/fonts/`, each with its license file. Keep fonts out of `addons/` unless their license permits shipping them with the addon.
- `demo/` holds a runnable demo scene that is the project's main scene. It is outside `addons/` so it is not shipped with the addon.

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

No test framework or linter is set up yet (candidates: GUT or gdUnit4 for tests, gdtoolkit's `gdlint` and `gdformat` for lint).

## Architecture

To be filled in when the code exists.
