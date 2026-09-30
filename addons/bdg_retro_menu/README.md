# BDG Retro Menu

An old-school panel menu for Godot 4: grid layouts, cascading submenus, and control by keyboard, mouse and gamepad.

## Input

The menu uses Godot's built-in `ui_*` actions and defines no input actions of its own:

| Action | Effect |
|---|---|
| `ui_up`, `ui_down`, `ui_left`, `ui_right` | Move the cursor. In a one-column panel, left goes back and right opens a submenu. |
| `ui_accept` | Choose the item or open its submenu. |
| `ui_cancel` | Go back one panel, or close the menu from the top level. |

The mouse also works: hover to highlight, left-click to choose, right-click or click outside the panel to go back, and the wheel to scroll.

**Gamepad:** in the author's project (Godot 4.7.2) the gamepad B button was not bound to `ui_cancel`, so it did nothing. If back does not work on your controller, bind a button to `ui_cancel` in Project Settings > Input Map. The demo does this in code for the east face button (Xbox B / PlayStation Circle).

## Fonts and styling

By default the menu uses Godot's built-in fallback font (`ThemeDB.fallback_font`), so the addon ships no font files. To change the look, assign a Theme with the type `RetroMenu` to the menu. It reads `font`, `font_size`, colors, the `panel` and `cursor` styleboxes, and the constants `item_padding`, `panel_offset_x` and `panel_offset_y`. The demo shows several pixel fonts this way.

## Credits

The design is inspired by the retro pop-up menu system by **OneLoneCoder** (javidx9):

- Video: <https://youtu.be/jde1Jq5dF0E>
- Source: <https://github.com/OneLoneCoder/Javidx9/blob/master/PixelGameEngine/SmallerProjects/OneLoneCoder_PGE_RetroMenu.cpp>

This is not a port. The code is a new implementation written for Godot.
