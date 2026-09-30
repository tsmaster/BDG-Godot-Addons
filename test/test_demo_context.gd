extends GdUnitTestSuite
## Covers the demo screens in demo/context/, mounted under a plain Context the
## way the demo's root does it.

var parent: Context
var settings: DemoSettings


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
