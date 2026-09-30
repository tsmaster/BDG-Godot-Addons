# gdlint: disable=max-public-methods
extends GdUnitTestSuite

enum Action { ATTACK, DEFEND, RUN }
enum Group { DIFFICULTY }

var menu: RetroMenu
var activated: Array[RetroMenuItem]
var toggled: Array[RetroMenuItem]
var moved: Array[RetroMenuItem]
var closed_count: int


## Counts ui_accept events that reach the unhandled-input stage.
class UnhandledCounter:
	extends Node

	var count := 0

	func _unhandled_input(event: InputEvent) -> void:
		if event.is_action_pressed(&"ui_accept"):
			count += 1


func before_test() -> void:
	activated = []
	toggled = []
	moved = []
	closed_count = 0
	menu = auto_free(RetroMenu.new())
	add_child(menu)
	menu.item_activated.connect(
		func(item: RetroMenuItem) -> void: activated.append(item)
	)
	menu.item_toggled.connect(
		func(item: RetroMenuItem) -> void: toggled.append(item)
	)
	menu.cursor_moved.connect(
		func(item: RetroMenuItem) -> void: moved.append(item)
	)
	menu.closed.connect(func() -> void: closed_count += 1)


## Sends a ui_* action through the viewport so it reaches the focused menu.
func _press(action: StringName) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	get_viewport().push_input(event)


func _simple_root() -> RetroMenuItem:
	var root := RetroMenuItem.new("main")
	root.add_item("Attack", Action.ATTACK)
	root.add_item("Defend", Action.DEFEND)
	root.add_item("Run", Action.RUN)
	return root


func test_open_and_close() -> void:
	assert_bool(menu.is_open()).is_false()
	menu.open(_simple_root())
	assert_bool(menu.is_open()).is_true()
	assert_bool(menu.visible).is_true()
	menu.close()
	assert_bool(menu.is_open()).is_false()
	assert_int(closed_count).is_equal(1)


func test_cursor_starts_on_first_item() -> void:
	var root := _simple_root()
	menu.open(root)
	assert_object(menu.current_item()).is_same(root.children[0])


func test_down_moves_cursor_and_emits_cursor_moved() -> void:
	var root := _simple_root()
	menu.open(root)
	_press(&"ui_down")
	assert_object(menu.current_item()).is_same(root.children[1])
	assert_int(moved.size()).is_equal(1)
	assert_object(moved[0]).is_same(root.children[1])


func test_up_from_first_wraps_to_last() -> void:
	var root := _simple_root()
	menu.open(root)
	_press(&"ui_up")
	assert_object(menu.current_item()).is_same(root.children[2])


func test_without_wrap_up_from_first_stays() -> void:
	var root := _simple_root()
	menu.wrap_around = false
	menu.open(root)
	_press(&"ui_up")
	assert_object(menu.current_item()).is_same(root.children[0])


func test_accept_activates_leaf_and_closes() -> void:
	var root := _simple_root()
	menu.open(root)
	_press(&"ui_accept")
	assert_int(activated.size()).is_equal(1)
	assert_object(activated[0]).is_same(root.children[0])
	assert_int(activated[0].id).is_equal(Action.ATTACK)
	assert_bool(menu.is_open()).is_false()
	assert_int(closed_count).is_equal(1)


func test_accept_keeps_menu_open_when_close_on_activate_is_off() -> void:
	menu.close_on_activate = false
	menu.open(_simple_root())
	_press(&"ui_accept")
	assert_int(activated.size()).is_equal(1)
	assert_bool(menu.is_open()).is_true()


func test_disabled_item_cannot_be_activated() -> void:
	var root := _simple_root()
	root.children[0].enabled = false
	menu.open(root)
	_press(&"ui_accept")
	assert_int(activated.size()).is_equal(0)
	assert_bool(menu.is_open()).is_true()


func test_right_activates_a_plain_item_in_a_single_column() -> void:
	menu.open(_simple_root())
	_press(&"ui_right")
	assert_int(activated.size()).is_equal(1)


func test_accept_on_submenu_opens_it_and_cancel_goes_back() -> void:
	var root := RetroMenuItem.new("main")
	root.add_item("Attack")
	var magic := root.add_submenu("Magic")
	var fire := magic.add_item("Fire")
	menu.open(root)
	_press(&"ui_down")
	_press(&"ui_accept")
	assert_object(menu.current_item()).is_same(fire)
	assert_int(activated.size()).is_equal(0)
	_press(&"ui_cancel")
	assert_object(menu.current_item()).is_same(magic)
	assert_bool(menu.is_open()).is_true()


func test_left_goes_back_in_a_single_column_panel() -> void:
	var root := RetroMenuItem.new("main")
	var magic := root.add_submenu("Magic")
	magic.add_item("Fire")
	menu.open(root)
	_press(&"ui_accept")
	_press(&"ui_left")
	assert_object(menu.current_item()).is_same(magic)


func test_cancel_at_top_level_closes_the_menu() -> void:
	menu.open(_simple_root())
	_press(&"ui_cancel")
	assert_bool(menu.is_open()).is_false()
	assert_int(closed_count).is_equal(1)


func test_left_and_right_move_within_a_grid() -> void:
	var root := RetroMenuItem.new("main")
	var grid := root.add_submenu("Grid", 3)
	var cells: Array[RetroMenuItem] = []
	for i in 6:
		cells.append(grid.add_item("Cell %d" % i))
	menu.open(root)
	_press(&"ui_accept")
	_press(&"ui_right")
	assert_object(menu.current_item()).is_same(cells[1])
	_press(&"ui_down")
	assert_object(menu.current_item()).is_same(cells[4])
	_press(&"ui_left")
	assert_object(menu.current_item()).is_same(cells[3])


func test_partial_last_row_clamps_the_cursor() -> void:
	var root := RetroMenuItem.new("main")
	var grid := root.add_submenu("Grid", 3)
	var cells: Array[RetroMenuItem] = []
	for i in 5:  # rows: 3 + 2, so column 2 of the last row is empty
		cells.append(grid.add_item("Cell %d" % i))
	menu.open(root)
	_press(&"ui_accept")
	_press(&"ui_right")
	_press(&"ui_right")
	_press(&"ui_down")
	assert_object(menu.current_item()).is_same(cells[4])


func test_checkbox_toggles_and_keeps_the_menu_open() -> void:
	var root := RetroMenuItem.new("main")
	var music := root.add_checkbox("Music", true)
	menu.open(root)
	_press(&"ui_accept")
	assert_bool(music.checked).is_false()
	assert_int(toggled.size()).is_equal(1)
	assert_object(toggled[0]).is_same(music)
	assert_int(activated.size()).is_equal(0)
	assert_bool(menu.is_open()).is_true()
	_press(&"ui_accept")
	assert_bool(music.checked).is_true()
	assert_int(toggled.size()).is_equal(2)


func test_right_does_not_toggle_a_checkbox() -> void:
	var root := RetroMenuItem.new("main")
	var music := root.add_checkbox("Music", true)
	menu.open(root)
	_press(&"ui_right")
	assert_bool(music.checked).is_true()
	assert_int(toggled.size()).is_equal(0)


func test_disabled_checkbox_does_not_toggle() -> void:
	var root := RetroMenuItem.new("main")
	var music := root.add_checkbox("Music", true)
	music.enabled = false
	menu.open(root)
	_press(&"ui_accept")
	assert_bool(music.checked).is_true()
	assert_int(toggled.size()).is_equal(0)


func test_radio_selects_exclusively_and_keeps_the_menu_open() -> void:
	var root := RetroMenuItem.new("main")
	var easy := root.add_radio("Easy", Group.DIFFICULTY, true)
	var hard := root.add_radio("Hard", Group.DIFFICULTY)
	menu.open(root)
	_press(&"ui_down")
	_press(&"ui_accept")
	assert_bool(easy.checked).is_false()
	assert_bool(hard.checked).is_true()
	assert_int(toggled.size()).is_equal(1)
	assert_object(toggled[0]).is_same(hard)
	assert_bool(menu.is_open()).is_true()


func test_choosing_the_selected_radio_again_does_nothing() -> void:
	var root := RetroMenuItem.new("main")
	var easy := root.add_radio("Easy", Group.DIFFICULTY, true)
	root.add_radio("Hard", Group.DIFFICULTY)
	menu.open(root)
	_press(&"ui_accept")
	assert_bool(easy.checked).is_true()
	assert_int(toggled.size()).is_equal(0)


func test_right_does_not_select_a_radio() -> void:
	var root := RetroMenuItem.new("main")
	root.add_radio("Easy", Group.DIFFICULTY, true)
	var hard := root.add_radio("Hard", Group.DIFFICULTY)
	menu.open(root)
	_press(&"ui_down")
	_press(&"ui_right")
	assert_bool(hard.checked).is_false()
	assert_int(toggled.size()).is_equal(0)


func test_event_is_handled_even_if_the_menu_leaves_the_tree_while_acting(
) -> void:
	var counter: UnhandledCounter = auto_free(UnhandledCounter.new())
	add_child(counter)
	# A listener that replaces the screen removes the menu from the tree.
	menu.item_activated.connect(
		func(_item: RetroMenuItem) -> void: remove_child(menu)
	)
	menu.open(_simple_root())
	_press(&"ui_accept")
	assert_int(activated.size()).is_equal(1)
	assert_int(counter.count).is_equal(0)
	menu.free()  # it is outside the tree, so nothing else will free it
