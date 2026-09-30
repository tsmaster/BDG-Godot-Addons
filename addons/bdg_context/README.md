# BDG Context

Scoped contexts for Godot 4, as a replacement for piles of autoloads. A
*context* is a `Node` that owns the services and state for one scope of a game
(the whole app, a game mode, a level). A parent context passes each child the
dependencies it needs, explicitly, and the child's lifetime is bounded by
`setup()` and `tear_down()`.

## Lifecycle

| Step | Who calls it | What it is for |
|---|---|---|
| `build()` | the mounting helper | Create services and child nodes. |
| `bind_dependencies(...)` | the parent's bind step | Receive what the parent passes in. |
| `setup()` | the mounting helper | Everything is resolved. May `await`. |
| `tear_down()` | the mounting helper | Undo `setup()`. Runs children first. |

`bind_dependencies()` is **not declared by the base class**. Each subclass
declares its own, with its own typed arguments. GDScript rejects an override
whose signature differs from its parent's, and a direct typed call keeps
compile-time checking of the arguments.

## Using it

```gdscript
class_name MainMenuContext
extends Context

var _settings: Settings

func bind_dependencies(settings: Settings) -> void:
	_settings = settings

func build() -> void:
	# create the menu nodes here
	pass

func setup() -> void:
	# _settings is available here
	pass
```

A parent writes one small mount function per child. It creates the child and
passes a bind step that calls the child's own `bind_dependencies()`:

```gdscript
func mount_main_menu() -> bool:
	var menu := MainMenuContext.new()
	return await replace_child(menu, func() -> void: menu.bind_dependencies(settings))
```

For a root context with no parent context, call `start()` from `_ready()`:

```gdscript
func _ready() -> void:
	await start()
	await mount_main_menu()
```

## The mounting helpers

- `replace_child(new_context, bind)` checks the new context, tears down and
  frees the current child, adds the new one, then runs `build()`, your bind
  step and `await setup()`. It returns `true` once the new context is set up,
  and `false` if it was refused or torn down while `setup()` ran.
- `unmount_child()` tears down and frees the current child.
- `get_child_context()` returns the mounted child, or `null`.
- `state` is `CREATED`, `BUILT`, `BOUND`, `READY` or `TORN_DOWN`.

## Async rules

- Only `setup()` may `await`. A `setup()` that does not await behaves exactly
  as a synchronous one.
- A second `replace_child()` on the same context while one is in progress is
  refused: it logs an error and returns `false`. Nothing is queued or
  cancelled, so `await` each mount before starting the next.
- Teardown is children first, in reverse order, then the context's own
  `tear_down()`. The helper frees the node afterwards, so a context never
  frees itself.
- GDScript has no exceptions, so a script error inside a hook cannot be
  caught and cleaned up after.

## Credits

The pattern comes from Hovering Skull's video
["Replacing autoloads with scoped contexts for scalable Godot architecture"](https://youtu.be/HkjOE4FbrXo)
([channel](https://www.youtube.com/@hoveringskull)), part of the free 3D
tactics RPG course. This is our own implementation of the idea, written
without seeing the code from the video.
