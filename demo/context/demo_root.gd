class_name DemoRoot
extends Context
## Root context. It owns the shared settings and mounts one screen at a time.
## Each mount_*() function is written out by hand so the call to the child's
## bind_dependencies() is type-checked.

var settings := DemoSettings.new()


func _ready() -> void:
	_bind_gamepad_cancel()
	await start()
	await mount_splash()
	await mount_main_menu()


func mount_splash() -> bool:
	var splash := DemoSplash.new()
	return await replace_child(
		splash, func() -> void: splash.bind_dependencies(1.5)
	)


func mount_main_menu() -> bool:
	var menu := DemoMainMenu.new()
	menu.mode_chosen.connect(_on_mode_chosen)
	return await replace_child(
		menu, func() -> void: menu.bind_dependencies("bdg_context demo")
	)


func mount_mode(title: String) -> bool:
	var stub := DemoModeStub.new()
	stub.back_requested.connect(mount_main_menu)
	return await replace_child(
		stub, func() -> void: stub.bind_dependencies(title, settings)
	)


func mount_settings() -> bool:
	var screen := DemoSettingsScreen.new()
	screen.back_requested.connect(mount_main_menu)
	return await replace_child(
		screen, func() -> void: screen.bind_dependencies(settings)
	)


func _on_mode_chosen(mode: int) -> void:
	match mode:
		DemoMainMenu.Mode.NEW_CAMPAIGN:
			mount_mode("New Campaign")
		DemoMainMenu.Mode.LOAD_SAVEGAME:
			mount_mode("Load Savegame")
		DemoMainMenu.Mode.SKIRMISH:
			mount_mode("Skirmish")
		DemoMainMenu.Mode.SETTINGS:
			mount_settings()
		DemoMainMenu.Mode.QUIT:
			get_tree().quit()


## The project has no gamepad binding for ui_cancel, so the demo adds the east
## face button (Xbox B / PlayStation Circle).
func _bind_gamepad_cancel() -> void:
	var back := InputEventJoypadButton.new()
	back.button_index = JOY_BUTTON_B
	if not InputMap.action_has_event(&"ui_cancel", back):
		InputMap.action_add_event(&"ui_cancel", back)
