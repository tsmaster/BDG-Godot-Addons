# bdg_context design

Status: decided in conversation, before implementation. Update this file if
the implementation departs from it.

## Origin and credit

The pattern comes from Hovering Skull's video "Replacing autoloads with scoped
contexts for scalable Godot architecture" (<https://youtu.be/HkjOE4FbrXo>,
channel <https://www.youtube.com/@hoveringskull>), part of the free 3D tactics
RPG course. The author's notes on it are in `godot_context_notes.md`. We have
not seen his code, so `bdg_context` is our own implementation of the idea.

## The idea

A *context* owns the services and state for one scope of a game (the whole
app, a game mode, a level), in place of global autoloads. A parent context
passes each child context the dependencies it needs, explicitly, and the
child's lifetime is bounded by `setup()` and `tear_down()`.

## Decisions

- **A context is a `Node`** in the scene tree. The parent chain, child scenes
  and `queue_free()` cleanup come for free.
- **No service registry, no automatic injection.** A parent passes what a child
  needs, explicitly.
- **`bind_dependencies()` is declared by each subclass, not by the base
  class.** Its arguments differ per context, and GDScript rejects a subclass
  override whose signature differs from the parent's ("The function signature
  doesn't match the parent", checked on Godot 4.7.2). A direct typed call keeps
  compile-time checking. The base class documents the convention only.
- **The base class provides** `build()`, `setup()` and `tear_down()` (all
  virtual, all optional), lifecycle state, and helpers to replace and remove a
  child context.
- **`setup()` may `await`.** A synchronous `setup()` behaves as before,
  because awaiting a non-coroutine returns at once. `build()`,
  `bind_dependencies()` and `tear_down()` are synchronous.
- **Mounting order** (in `replace_child()`): check the new context, tear down
  and free the old child, add the new one to the tree, then `build()`, the
  caller's bind step, `await setup()`. This differs from the video in one
  way: the new context is checked *before* the old one is removed, so a bad
  argument does not leave nothing mounted.
- **Teardown order:** children first, in reverse order of the children's
  order in the tree, then the context's own `tear_down()`. The helper frees the
  node after `tear_down()` returns; a context never frees itself.
- **Guardrails around async:**
  - A second `replace_child()` on the same parent while one is in progress is
    refused with an error and returns `false`. Nothing is queued or cancelled.
  - After `await setup()`, the helper checks that the new context is still
    valid and not torn down, and returns `false` if not.
  - Each context tracks a state: `CREATED`, `BUILT`, `BOUND`, `READY`,
    `TORN_DOWN`.
  - GDScript has no exceptions, so a script error inside a hook cannot be
    caught and cleaned up after. The helper only handles what it can detect.

## API sketch

```gdscript
class_name Context
extends Node

enum State { CREATED, BUILT, BOUND, READY, TORN_DOWN }

var state := State.CREATED

func build() -> void: pass                # create services and children
func setup() -> void: pass                # may await
func tear_down() -> void: pass            # paired with setup()

func start() -> void                      # for a root context
func replace_child(new_context: Context, bind := Callable()) -> bool  # async
func unmount_child() -> void
func get_child_context() -> Context
```

A parent's typed mount function does the wiring:

```gdscript
func mount_main_menu() -> bool:
	var menu := MainMenuContext.new()
	return await replace_child(menu, func() -> void:
		menu.bind_dependencies(settings, save_store))
```

## Naming

Addon: `bdg_context`. Class: `Context`. The hook is `tear_down()`, and the
helper that removes a child is `unmount_child()`.

## Demo

`demo/context/`: a root context mounts a splash context (its `setup()` awaits a
fake loading sequence), then a main menu (built with `bdg_retro_menu`) offering
New Campaign, Load Savegame, Skirmish, Settings and Quit. Each mode is a child
context that returns to the menu. The Settings screen uses the retro menu's
checkboxes and radio buttons.
