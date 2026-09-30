extends GdUnitTestSuite

enum Action { ATTACK, CAST }
enum Group { DIFFICULTY, MODE }


func test_add_item_appends_and_returns_the_child() -> void:
	var root := RetroMenuItem.new("main")
	var item := root.add_item("Attack", Action.ATTACK)
	assert_int(root.children.size()).is_equal(1)
	assert_object(root.children[0]).is_same(item)
	assert_str(item.text).is_equal("Attack")
	assert_int(item.id).is_equal(Action.ATTACK)
	assert_bool(item.enabled).is_true()
	assert_int(item.type).is_equal(RetroMenuItem.Type.ACTION)


func test_is_submenu_depends_on_children() -> void:
	var root := RetroMenuItem.new("main")
	assert_bool(root.is_submenu()).is_false()
	root.add_item("Attack")
	assert_bool(root.is_submenu()).is_true()


func test_add_submenu_sets_layout() -> void:
	var root := RetroMenuItem.new("main")
	var magic := root.add_submenu("Magic", 3, 4)
	assert_int(magic.columns).is_equal(3)
	assert_int(magic.max_visible_rows).is_equal(4)


func test_metadata_round_trips_any_value() -> void:
	var item := RetroMenuItem.new("Fire")
	item.metadata = {"mp": 4}
	assert_int(item.metadata.mp).is_equal(4)


func test_add_checkbox_sets_type_and_state() -> void:
	var root := RetroMenuItem.new("main")
	var on := root.add_checkbox("Music", true, 5)
	var off := root.add_checkbox("Fullscreen")
	assert_int(on.type).is_equal(RetroMenuItem.Type.CHECKBOX)
	assert_bool(on.checked).is_true()
	assert_int(on.id).is_equal(5)
	assert_bool(off.checked).is_false()


func test_add_radio_checked_takes_selection_from_group() -> void:
	var root := RetroMenuItem.new("main")
	var first := root.add_radio("Easy", Group.DIFFICULTY, true)
	var second := root.add_radio("Hard", Group.DIFFICULTY, true)
	assert_bool(first.checked).is_false()
	assert_bool(second.checked).is_true()


func test_radio_groups_are_independent() -> void:
	var root := RetroMenuItem.new("main")
	var difficulty := root.add_radio("Easy", Group.DIFFICULTY, true)
	var mode := root.add_radio("Solo", Group.MODE, true)
	root.select_radio(root.add_radio("Hard", Group.DIFFICULTY))
	assert_bool(difficulty.checked).is_false()
	assert_bool(mode.checked).is_true()


func test_select_radio_clears_the_rest_of_the_group() -> void:
	var root := RetroMenuItem.new("main")
	var a := root.add_radio("A", Group.DIFFICULTY, true)
	var b := root.add_radio("B", Group.DIFFICULTY)
	root.select_radio(b)
	assert_bool(a.checked).is_false()
	assert_bool(b.checked).is_true()


func test_get_selected_radio() -> void:
	var root := RetroMenuItem.new("main")
	root.add_radio("A", Group.DIFFICULTY)
	var b := root.add_radio("B", Group.DIFFICULTY, true)
	assert_object(root.get_selected_radio(Group.DIFFICULTY)).is_same(b)
	assert_object(root.get_selected_radio(Group.MODE)).is_null()
