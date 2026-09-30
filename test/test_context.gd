extends GdUnitTestSuite

var parent: Context
var events: Array[String]


## A context that records its lifecycle calls in a shared list.
class Probe:
	extends Context

	signal gate

	var tag: String
	var log: Array[String]
	var bound_with := ""
	var setup_frames := 0
	var wait_for_gate := false
	var grandchildren := 0

	func _init(p_tag: String, p_log: Array[String]) -> void:
		tag = p_tag
		log = p_log

	func build() -> void:
		log.append("build " + tag)
		for i in grandchildren:
			var grandchild := Probe.new("%s.%d" % [tag, i], log)
			add_child(grandchild)
			# Pretend it was mounted, so tear_down() has something to undo.
			grandchild.state = Context.State.BUILT

	func bind_dependencies(text: String) -> void:
		bound_with = text
		log.append("bind " + tag)

	func setup() -> void:
		for i in setup_frames:
			await get_tree().process_frame
		if wait_for_gate:
			await gate
		log.append("setup " + tag)

	func tear_down() -> void:
		log.append("tear_down " + tag)


func before_test() -> void:
	events = []
	parent = auto_free(Context.new())
	add_child(parent)


func after_test() -> void:
	# Let queue_free() of removed contexts finish before orphans are counted.
	await get_tree().process_frame


func test_start_runs_build_then_setup_and_becomes_ready() -> void:
	var root: Probe = auto_free(Probe.new("root", events))
	add_child(root)
	await root.start()
	assert_array(events).is_equal(["build root", "setup root"])
	assert_int(root.state).is_equal(Context.State.READY)


func test_replace_child_runs_the_lifecycle_in_order() -> void:
	var child := Probe.new("a", events)
	var mounted: bool = await parent.replace_child(
		child, func() -> void: child.bind_dependencies("hello")
	)
	assert_bool(mounted).is_true()
	assert_array(events).is_equal(["build a", "bind a", "setup a"])
	assert_str(child.bound_with).is_equal("hello")
	assert_int(child.state).is_equal(Context.State.READY)
	assert_object(child.get_parent()).is_same(parent)
	assert_object(parent.get_child_context()).is_same(child)


func test_bind_step_is_optional() -> void:
	var child := Probe.new("a", events)
	await parent.replace_child(child)
	assert_array(events).is_equal(["build a", "setup a"])


func test_setup_can_await_and_the_context_is_not_ready_until_it_finishes(
) -> void:
	var child := Probe.new("slow", events)
	child.setup_frames = 3
	parent.replace_child(child)
	assert_int(child.state).is_equal(Context.State.BOUND)
	assert_array(events).is_equal(["build slow"])
	for i in 4:
		await get_tree().process_frame
	assert_array(events).is_equal(["build slow", "setup slow"])
	assert_int(child.state).is_equal(Context.State.READY)


func test_replacing_tears_down_the_old_child_before_building_the_new_one(
) -> void:
	var first := Probe.new("a", events)
	var second := Probe.new("b", events)
	await parent.replace_child(first)
	await parent.replace_child(second)
	assert_array(events).is_equal(
		["build a", "setup a", "tear_down a", "build b", "setup b"]
	)
	assert_int(first.state).is_equal(Context.State.TORN_DOWN)
	assert_object(parent.get_child_context()).is_same(second)
	await get_tree().process_frame
	assert_bool(is_instance_valid(first)).is_false()


func test_teardown_runs_children_first_and_in_reverse_order() -> void:
	var child := Probe.new("a", events)
	child.grandchildren = 2
	await parent.replace_child(child)
	events.clear()
	parent.unmount_child()
	assert_array(events).is_equal(
		["tear_down a.1", "tear_down a.0", "tear_down a"]
	)


func test_unmount_child_frees_the_context_and_clears_the_slot() -> void:
	var child := Probe.new("a", events)
	await parent.replace_child(child)
	parent.unmount_child()
	assert_object(parent.get_child_context()).is_null()
	assert_int(child.state).is_equal(Context.State.TORN_DOWN)
	await get_tree().process_frame
	assert_bool(is_instance_valid(child)).is_false()


func test_unmount_child_with_nothing_mounted_does_nothing() -> void:
	parent.unmount_child()
	assert_object(parent.get_child_context()).is_null()


func test_null_context_is_refused_and_the_current_child_stays() -> void:
	var child := Probe.new("a", events)
	await parent.replace_child(child)
	var refused := [true]
	await (
		assert_error(
			func() -> void: refused[0] = await parent.replace_child(null)
		)
		. is_push_error("Context.replace_child(): the new context is null.")
	)
	assert_bool(refused[0]).is_false()
	assert_object(parent.get_child_context()).is_same(child)
	assert_int(child.state).is_equal(Context.State.READY)


func test_a_used_context_cannot_be_mounted_again() -> void:
	var child := Probe.new("a", events)
	await parent.replace_child(child)
	var other: Context = auto_free(Context.new())
	add_child(other)
	var result := [true]
	await (
		assert_error(
			func() -> void: result[0] = await other.replace_child(child)
		)
		. is_push_error(
			(
				"Context.replace_child(): the new context must be a fresh, "
				+ "unparented context."
			)
		)
	)
	assert_bool(result[0]).is_false()
	assert_object(other.get_child_context()).is_null()


func test_overlapping_mount_is_refused() -> void:
	var slow := Probe.new("slow", events)
	slow.setup_frames = 3
	var other := Probe.new("other", events)
	parent.replace_child(slow)
	var result := [true]
	await (
		assert_error(
			func() -> void: result[0] = await parent.replace_child(other)
		)
		. is_push_error(
			"Context.replace_child(): a mount is already in progress."
		)
	)
	assert_bool(result[0]).is_false()
	other.free()
	for i in 4:
		await get_tree().process_frame
	assert_object(parent.get_child_context()).is_same(slow)
	assert_int(slow.state).is_equal(Context.State.READY)


func test_context_torn_down_during_setup_is_reported_as_not_mounted() -> void:
	var child := Probe.new("gated", events)
	child.wait_for_gate = true
	var result := []
	(func() -> void: result.append(await parent.replace_child(child))).call()
	assert_array(result).is_empty()
	parent.unmount_child()
	child.gate.emit()
	assert_array(result).is_equal([false])
	assert_int(child.state).is_equal(Context.State.TORN_DOWN)


func test_a_new_mount_is_allowed_after_the_previous_one_finished() -> void:
	var first := Probe.new("a", events)
	first.setup_frames = 2
	await parent.replace_child(first)
	var second := Probe.new("b", events)
	var mounted: bool = await parent.replace_child(second)
	assert_bool(mounted).is_true()
