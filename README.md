# BDG Godot Addons

A collection of small, independent, reusable addons for the [Godot](https://godotengine.org) game engine, written in GDScript.

Tested with Godot 4.7.2 stable and 4.8-dev6.

## Addons

| Addon | Description |
|---|---|
| [`bdg_retro_menu`](addons/bdg_retro_menu/) | Old-school panel menu with grid layouts, cascading submenus, and keyboard, mouse and gamepad control. |

Each addon lives in its own folder under `addons/` and can be copied into your project on its own.

## Trying the demo

Open the project in Godot, or run it from a terminal:

```
godot --path .
```

On a fresh checkout, register the addon's classes once first:

```
godot --headless --path . --import
```

The demo scene shows the retro menu. Press **1** to **4** to switch between the default font, Press Start 2P, Silkscreen and Kenney Pixel.

## Using an addon

Copy the addon's folder (for example `addons/bdg_retro_menu/`) into your project's `addons/` folder and enable it under Project > Project Settings > Plugins. See the addon's own README for details.

## Credits

- The retro menu is inspired by the retro pop-up menu by **OneLoneCoder** (javidx9). See the [`bdg_retro_menu` README](addons/bdg_retro_menu/README.md#credits) for links.
- The demo fonts in `demo/fonts/` have their own licenses, and each font's license file is next to it:
  - Press Start 2P and Silkscreen: SIL Open Font License
  - Kenney Pixel: CC0

## License

The code is released under the [MIT License](LICENSE). The fonts in `demo/fonts/` are covered by their own licenses, listed above.
