extends Control

## Ids for the menu items. The menu itself only sees ints.
enum Action { ATTACK, DEFEND, CAST, ITEMS, RUN, MUSIC, SOUND, FULLSCREEN }

## Font choices for comparison. Pixel fonts look sharpest at multiples of their design size.
const FONTS := [
	{"key": KEY_1, "name": "Default", "path": "", "size": 16},
	{"key": KEY_2, "name": "Press Start 2P", "path": "res://demo/fonts/PressStart2P-Regular.ttf", "size": 16, "offset": Vector2i(32, 32)},
	{"key": KEY_3, "name": "Silkscreen", "path": "res://demo/fonts/Silkscreen-Regular.ttf", "size": 16},
	{"key": KEY_4, "name": "Kenney Pixel", "path": "res://demo/fonts/KenneyPixel.ttf", "size": 16},
	{"key": KEY_5, "name": "Print Char 21 (Apple II 40-column)", "path": "res://demo/fonts/PrintChar21.ttf", "size": 16},
	{"key": KEY_6, "name": "PR Number 3 (Apple II 80-column)", "path": "res://demo/fonts/PRNumber3.ttf", "size": 16},
	{"key": KEY_7, "name": "Hack (smooth, not pixel)", "path": "res://demo/fonts/Hack-Regular.ttf", "size": 16, "smooth": true},
]

var _menu: RetroMenu
var _label: Label
var _root: RetroMenuItem  # built once, so checkbox state survives closing and reopening


func _ready() -> void:
	_bind_gamepad_cancel()

	_label = Label.new()
	_label.position = Vector2(400, 16)
	_label.text = "Press 1-7 to change font (Default, Press Start 2P, Silkscreen, Kenney Pixel, Print Char 21, PR Number 3, Hack)"
	add_child(_label)

	_menu = RetroMenu.new()
	_menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_menu)
	_menu.item_activated.connect(func(item: RetroMenuItem) -> void:
		_on_item_activated(item))
	_menu.item_toggled.connect(func(item: RetroMenuItem) -> void:
		_label.text = "%s is now %s" % [item.text, "on" if item.checked else "off"])
	_menu.closed.connect(func() -> void: _label.text += "  [closed - press Enter to reopen]")

	_menu.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_root = _build_menu()
	_menu.open(_root)


func _on_item_activated(item: RetroMenuItem) -> void:
	match item.id:
		Action.CAST:
			# The spell data travels with the item in its metadata.
			var spell: Dictionary = item.metadata
			_label.text = "Cast %s (costs %d MP)" % [spell.name, spell.mp]
		_:
			_label.text = "Chose: %s (%s)" % [item.text, Action.find_key(item.id)]


## The project has no gamepad binding for ui_cancel, so the demo adds the east
## face button (Xbox B / PlayStation Circle). Real projects should set this in
## Project Settings > Input Map instead.
func _bind_gamepad_cancel() -> void:
	var back := InputEventJoypadButton.new()
	back.button_index = JOY_BUTTON_B
	if not InputMap.action_has_event(&"ui_cancel", back):
		InputMap.action_add_event(&"ui_cancel", back)


func _apply_font(choice: Dictionary) -> void:
	var menu_theme := Theme.new()
	if choice.path != "":
		var font: FontFile = load(choice.path)
		# Pixel fonts need crisp, unsmoothed rendering; smooth fonts keep Godot's defaults.
		var smooth: bool = choice.get("smooth", false)
		font.antialiasing = TextServer.FONT_ANTIALIASING_GRAY if smooth else TextServer.FONT_ANTIALIASING_NONE
		font.hinting = TextServer.HINTING_LIGHT if smooth else TextServer.HINTING_NONE
		font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_AUTO if smooth else TextServer.SUBPIXEL_POSITIONING_DISABLED
		menu_theme.set_font(&"font", &"RetroMenu", font)
	menu_theme.set_font_size(&"font_size", &"RetroMenu", choice.size)
	if choice.has("offset"):
		menu_theme.set_constant(&"panel_offset_x", &"RetroMenu", choice.offset.x)
		menu_theme.set_constant(&"panel_offset_y", &"RetroMenu", choice.offset.y)
	_menu.theme = menu_theme
	_menu.queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		for choice in FONTS:
			if event.keycode == choice.key:
				_apply_font(choice)
				return
	if event.is_action_pressed(&"ui_accept") and not _menu.is_open():
		_menu.open(_root)
		get_viewport().set_input_as_handled()


func _build_menu() -> RetroMenuItem:
	var root := RetroMenuItem.new("main")
	root.add_item("Attack", Action.ATTACK)
	root.add_item("Defend", Action.DEFEND)
	var magic := root.add_submenu("Magic")
	var white := magic.add_submenu("White", 3, 4)
	var white_spells := [
		{"name": "Cure", "mp": 4}, {"name": "Cura", "mp": 9}, {"name": "Curaga", "mp": 20},
		{"name": "Raise", "mp": 12}, {"name": "Esuna", "mp": 6}, {"name": "Protect", "mp": 5},
		{"name": "Shell", "mp": 5}, {"name": "Regen", "mp": 8}, {"name": "Holy", "mp": 30},
	]
	for spell in white_spells:
		white.add_item(spell.name, Action.CAST).metadata = spell
	var black := magic.add_submenu("Black")
	for spell in [{"name": "Fire", "mp": 4}, {"name": "Blizzard", "mp": 4}, {"name": "Thunder", "mp": 4}]:
		black.add_item(spell.name, Action.CAST).metadata = spell
	root.add_item("Items", Action.ITEMS).enabled = false
	var settings := root.add_submenu("Settings")
	settings.add_checkbox("Music", true, Action.MUSIC)
	settings.add_checkbox("Sound effects", true, Action.SOUND)
	settings.add_checkbox("Fullscreen", false, Action.FULLSCREEN)
	root.add_item("Run", Action.RUN)
	return root
