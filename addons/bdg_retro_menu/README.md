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

## Reacting to the menu

Build a tree of `RetroMenuItem`, open it, and connect to `item_activated`. The signal fires only for leaf items and passes the item. Submenus open and close on their own.

```gdscript
enum Action { ATTACK, CAST, RUN }

var root := RetroMenuItem.new("main")
root.add_item("Attack", Action.ATTACK)
var magic := root.add_submenu("Magic")
magic.add_item("Fire", Action.CAST).metadata = fire_spell   # any value your game wants
root.add_item("Run", Action.RUN)

menu.item_activated.connect(_on_item)
menu.open(root)

func _on_item(item: RetroMenuItem) -> void:
    match item.id:
        Action.ATTACK: attack()
        Action.CAST: cast(item.metadata as Spell)
        Action.RUN: run_away()
```

- **`id`** is an `int`. Use an enum from your own game so typos are caught when the script is parsed. The value comes back as an `int`, so cast it (`item.id as Action`) if you want the enum type.
- **`metadata`** is a `Variant` that the menu never touches. It is handy for menus built from data, such as spells or inventory.
- **Checkboxes:** `add_checkbox("Music", true, Action.MUSIC)` adds an item drawn as `[x]` or `[ ]` before its text. Choosing it (`ui_accept` or click) flips `item.checked` and emits `item_toggled(item)`. The menu stays open, whatever `close_on_activate` is. `ui_right` never toggles a checkbox. Read or set `checked` on the item at any time. Keep the same item tree between openings if you want the state to persist.
- Other signals: `cursor_moved(item)` when the highlight changes, and `closed` when the menu closes.
- If you want strong typing for the extra data, subclass `RetroMenuItem` and append your own instances to `children`.

## Fonts and styling

By default the menu uses Godot's built-in fallback font (`ThemeDB.fallback_font`), so the addon ships no font files. To change the look, assign a Theme with the type `RetroMenu` to the menu. It reads `font`, `font_size`, colors, the `panel` and `cursor` styleboxes, and the constants `item_padding`, `panel_offset_x` and `panel_offset_y`. The demo shows several pixel fonts this way.

## Credits

The design is inspired by the retro pop-up menu system by **OneLoneCoder** (javidx9):

- Video: <https://youtu.be/jde1Jq5dF0E>
- Source: <https://github.com/OneLoneCoder/Javidx9/blob/master/PixelGameEngine/SmallerProjects/OneLoneCoder_PGE_RetroMenu.cpp>

This is not a port. The code is a new implementation written for Godot.
