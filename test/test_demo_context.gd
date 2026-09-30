extends GdUnitTestSuite
## Covers the demo screens in demo/context/, mounted under a plain Context the
## way the demo's root does it.

var parent: Context
var settings: DemoSettings


## The demo's root context without its splash sequence, so tests can drive the
## mount functions themselves.
class QuietRoot:
	extends DemoRoot

	func _ready() -> void:
		pass


func before_test() -> void:
	settings = DemoSettings.new()
	parent = auto_free(Context.new())
	add_child(parent)


func after_test() -> void:
	# Let queue_free() of removed contexts finish before orphans are counted.
	await get_tree().process_frame


func _press(action: StringName) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	get_viewport().push_input(event)


func test_splash_mounts_after_its_loading_sequence() -> void:
	var splash := DemoSplash.new()
	var mounted: bool = await parent.replace_child(
		splash, func() -> void: splash.bind_dependencies(0.05)
	)
	assert_bool(mounted).is_true()
	assert_int(splash.state).is_equal(Context.State.READY)


func test_main_menu_reports_the_chosen_mode() -> void:
	var menu := DemoMainMenu.new()
	await parent.replace_child(
		menu, func() -> void: menu.bind_dependencies("t")
	)
	var chosen: Array[int] = []
	menu.mode_chosen.connect(func(mode: int) -> void: chosen.append(mode))
	for i in 3:
		_press(&"ui_down")
	_press(&"ui_accept")
	assert_array(chosen).is_equal([DemoMainMenu.Mode.SETTINGS])


func test_main_menu_stays_open_after_a_choice() -> void:
	var menu := DemoMainMenu.new()
	await parent.replace_child(
		menu, func() -> void: menu.bind_dependencies("t")
	)
	_press(&"ui_accept")
	_press(&"ui_cancel")
	_press(&"ui_down")
	_press(&"ui_accept")
	var chosen: Array[int] = []
	menu.mode_chosen.connect(func(mode: int) -> void: chosen.append(mode))
	_press(&"ui_accept")
	assert_array(chosen).is_equal([DemoMainMenu.Mode.LOAD_SAVEGAME])


func test_mode_stub_goes_back_on_cancel() -> void:
	var stub := DemoModeStub.new()
	await parent.replace_child(
		stub, func() -> void: stub.bind_dependencies("Skirmish", settings)
	)
	var back: Array[bool] = []
	stub.back_requested.connect(func() -> void: back.append(true))
	_press(&"ui_cancel")
	assert_array(back).is_equal([true])


func test_settings_screen_writes_toggles_back_to_the_bound_settings() -> void:
	var screen := DemoSettingsScreen.new()
	await parent.replace_child(
		screen, func() -> void: screen.bind_dependencies(settings)
	)
	_press(&"ui_accept")
	assert_bool(settings.music_on).is_false()
	_press(&"ui_down")
	_press(&"ui_accept")
	assert_bool(settings.sound_on).is_false()
	for i in 3:
		_press(&"ui_down")
	_press(&"ui_accept")
	assert_int(settings.difficulty).is_equal(DemoSettings.Difficulty.HARD)


func test_settings_screen_starts_from_the_bound_settings() -> void:
	settings.music_on = false
	settings.difficulty = DemoSettings.Difficulty.EASY
	var screen := DemoSettingsScreen.new()
	await parent.replace_child(
		screen, func() -> void: screen.bind_dependencies(settings)
	)
	# Music starts off, so choosing it turns it on.
	_press(&"ui_accept")
	assert_bool(settings.music_on).is_true()


func test_settings_screen_asks_to_go_back() -> void:
	var screen := DemoSettingsScreen.new()
	await parent.replace_child(
		screen, func() -> void: screen.bind_dependencies(settings)
	)
	var back: Array[bool] = []
	screen.back_requested.connect(func() -> void: back.append(true))
	_press(&"ui_cancel")
	assert_array(back).is_equal([true])


func _quiet_root() -> QuietRoot:
	var root: QuietRoot = auto_free(QuietRoot.new())
	add_child(root)
	return root


## Main menu -> Skirmish, leaving the skirmish menu mounted.
func _open_skirmish_menu(root: QuietRoot) -> void:
	await root.mount_main_menu()
	_press(&"ui_down")
	_press(&"ui_down")
	_press(&"ui_accept")


func test_skirmish_menu_reports_each_choice() -> void:
	var menu := DemoSkirmishMenu.new()
	await parent.replace_child(menu)
	var chosen: Array[int] = []
	menu.choice_made.connect(func(choice: int) -> void: chosen.append(choice))
	_press(&"ui_accept")
	_press(&"ui_down")
	_press(&"ui_accept")
	assert_array(chosen).is_equal(
		[
			DemoSkirmishMenu.Choice.ARENA_RUMBLE,
			DemoSkirmishMenu.Choice.BARREL_CHASE
		]
	)


func test_skirmish_menu_back_item_and_cancel_both_ask_to_go_back() -> void:
	var menu := DemoSkirmishMenu.new()
	await parent.replace_child(menu)
	var back: Array[bool] = []
	menu.back_requested.connect(func() -> void: back.append(true))
	_press(&"ui_cancel")
	assert_int(back.size()).is_equal(1)
	# The top-level cancel closed the menu, so reopen it the way a player would.
	parent.unmount_child()
	var again := DemoSkirmishMenu.new()
	await parent.replace_child(again)
	again.back_requested.connect(func() -> void: back.append(true))
	_press(&"ui_up")
	_press(&"ui_accept")
	assert_int(back.size()).is_equal(2)


func test_skirmish_leads_to_arena_rumble_and_finishing_returns_to_the_main_menu(
) -> void:
	var root := _quiet_root()
	await _open_skirmish_menu(root)
	assert_object(root.get_child_context()).is_instanceof(DemoSkirmishMenu)
	_press(&"ui_accept")
	assert_object(root.get_child_context()).is_instanceof(DemoArenaRumble)
	_press(&"ui_accept")
	assert_object(root.get_child_context()).is_instanceof(DemoMainMenu)


func test_skirmish_leads_to_barrel_chase_and_finishing_returns_to_the_main_menu(
) -> void:
	var root := _quiet_root()
	await _open_skirmish_menu(root)
	_press(&"ui_down")
	_press(&"ui_accept")
	assert_object(root.get_child_context()).is_instanceof(DemoBarrelChase)
	_press(&"ui_accept")
	assert_object(root.get_child_context()).is_instanceof(DemoMainMenu)


func test_abandoning_a_match_returns_to_the_skirmish_menu() -> void:
	var root := _quiet_root()
	await _open_skirmish_menu(root)
	_press(&"ui_accept")
	assert_object(root.get_child_context()).is_instanceof(DemoArenaRumble)
	_press(&"ui_cancel")
	assert_object(root.get_child_context()).is_instanceof(DemoSkirmishMenu)


func test_cancelling_out_of_the_skirmish_menu_returns_to_the_main_menu(
) -> void:
	var root := _quiet_root()
	await _open_skirmish_menu(root)
	_press(&"ui_cancel")
	assert_object(root.get_child_context()).is_instanceof(DemoMainMenu)


func test_the_same_route_works_twice_in_a_row() -> void:
	var root := _quiet_root()
	for round in 2:
		await _open_skirmish_menu(root)
		_press(&"ui_accept")
		_press(&"ui_accept")
		assert_object(root.get_child_context()).is_instanceof(DemoMainMenu)
