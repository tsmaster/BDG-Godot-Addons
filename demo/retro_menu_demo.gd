extends Control

## Font choices for comparison. Pixel fonts look sharpest at multiples of their design size.
const FONTS := [
	{"key": KEY_1, "name": "Default", "path": "", "size": 16},
	{"key": KEY_2, "name": "Press Start 2P", "path": "res://demo/fonts/PressStart2P-Regular.ttf", "size": 16, "offset": Vector2i(32, 32)},
	{"key": KEY_3, "name": "Silkscreen", "path": "res://demo/fonts/Silkscreen-Regular.ttf", "size": 16},
	{"key": KEY_4, "name": "Kenney Pixel", "path": "res://demo/fonts/KenneyPixel.ttf", "size": 16},
	{"key": KEY_5, "name": "Print Char 21 (Apple II 40-column)", "path": "res://demo/fonts/PrintChar21.ttf", "size": 16},
	{"key": KEY_6, "name": "PR Number 3 (Apple II 80-column)", "path": "res://demo/fonts/PRNumber3.ttf", "size": 16},
]

var _menu: RetroMenu
var _label: Label


func _ready() -> void:
	_bind_gamepad_cancel()

	_label = Label.new()
	_label.position = Vector2(400, 16)
	_label.text = "Press 1-6 to change font (Default, Press Start 2P, Silkscreen, Kenney Pixel, Print Char 21, PR Number 3)"
	add_child(_label)

	_menu = RetroMenu.new()
	_menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_menu)
	_menu.item_activated.connect(func(item: RetroMenuItem) -> void:
		_label.text = "Chose: %s (id %d)" % [item.text, item.id])
	_menu.closed.connect(func() -> void: _label.text += "  [closed - press Enter to reopen]")

	_menu.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_menu.open(_build_menu())


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
		font.antialiasing = TextServer.FONT_ANTIALIASING_NONE
		font.hinting = TextServer.HINTING_NONE
		font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
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
		_menu.open(_build_menu())
		get_viewport().set_input_as_handled()


func _build_menu() -> RetroMenuItem:
	var root := RetroMenuItem.new("main")
	root.add_item("Attack", 101)
	root.add_item("Defend", 102)
	var magic := root.add_submenu("Magic")
	var white := magic.add_submenu("White", 3, 4)
	for spell in ["Cure", "Cura", "Curaga", "Raise", "Esuna", "Protect", "Shell", "Regen", "Holy"]:
		white.add_item(spell)
	var black := magic.add_submenu("Black")
	for spell in ["Fire", "Blizzard", "Thunder"]:
		black.add_item(spell)
	var items := root.add_item("Items", 103)
	items.enabled = false
	root.add_item("Run", 104)
	return root
