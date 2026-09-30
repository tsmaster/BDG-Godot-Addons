class_name Context
extends Node
## A scoped owner of services and state, in place of global autoloads.
##
## Lifecycle, in order:
##   build()               create services and child nodes
##   bind_dependencies()   receive what the parent passes in (declared by each
##                         subclass with its own typed arguments, so it is not
##                         declared here)
##   setup()               everything is resolved; may await
##   tear_down()           undo setup(), just before the context is freed
##
## A parent mounts a child with replace_child(), passing a bind step that
## calls the child's own typed bind_dependencies():
##
##   var menu := MainMenuContext.new()
##   await replace_child(menu, func() -> void: menu.bind_dependencies(a, b))
##
## See docs/context_design.md for the reasoning behind these rules.

enum State { CREATED, BUILT, BOUND, READY, TORN_DOWN }

## Where this context is in its lifecycle. Set by the mounting helpers.
var state := State.CREATED

var _child: Context
var _mounting := false


## Create services and child nodes. Runs before dependencies are bound.
func build() -> void:
	pass


## All dependencies are resolved, so do any setup necessary. May await, for
## example to load resources over several frames.
func setup() -> void:
	pass


## Undo setup(). Runs children-first, just before the context is freed. The
## mounting helper frees the node; do not free it here.
func tear_down() -> void:
	pass


## The context currently mounted with replace_child(), or null.
func get_child_context() -> Context:
	if is_instance_valid(_child):
		return _child
	return null


## Runs build() and setup() for a root context that has no parent context and
## no dependencies. Call it from _ready(), and await it if you need to know
## when setup() has finished.
func start() -> void:
	if state != State.CREATED:
		push_error("Context.start(): already started (state %s)." % state)
		return
	build()
	state = State.BUILT
	state = State.BOUND
	await setup()
	if is_instance_valid(self) and state == State.BOUND:
		state = State.READY


## Replaces the mounted child with `new_context` and runs its lifecycle:
## build(), then `bind` (if given), then await setup().
##
## `bind` is where you call the new context's own typed bind_dependencies().
## Returns true when the new context is set up, and false when it was refused
## or was freed while setup() ran. Refusals log an error and change nothing:
##   - another replace_child() on this context is still in progress
##   - `new_context` is null, freed, already in use, or has a parent
func replace_child(new_context: Context, bind := Callable()) -> bool:
	if _mounting:
		push_error("Context.replace_child(): a mount is already in progress.")
		return false
	if not _is_mountable(new_context):
		return false

	_mounting = true
	unmount_child()
	add_child(new_context)
	_child = new_context

	new_context.build()
	new_context.state = State.BUILT
	if bind.is_valid():
		bind.call()
	new_context.state = State.BOUND
	await new_context.setup()

	_mounting = false
	if (
		not is_instance_valid(new_context)
		or new_context.state == State.TORN_DOWN
	):
		return false
	new_context.state = State.READY
	return true


## Tears down and frees the mounted child, if there is one.
func unmount_child() -> void:
	var old := _child
	_child = null
	if not is_instance_valid(old):
		return
	old._tear_down_tree()
	if old.get_parent() == self:
		remove_child(old)
	old.queue_free()


func _is_mountable(new_context: Context) -> bool:
	if new_context == null or not is_instance_valid(new_context):
		push_error("Context.replace_child(): the new context is null.")
		return false
	if new_context.state != State.CREATED or new_context.get_parent() != null:
		push_error(
			(
				"Context.replace_child(): the new context must be a fresh, "
				+ "unparented context."
			)
		)
		return false
	return true


## Tears down this context's child contexts (last child first), then this one.
func _tear_down_tree() -> void:
	if state == State.TORN_DOWN:
		return
	var children := get_children()
	children.reverse()
	for child in children:
		if child is Context:
			child._tear_down_tree()
	# A context that never got built has nothing to undo.
	if state != State.CREATED:
		tear_down()
	state = State.TORN_DOWN
