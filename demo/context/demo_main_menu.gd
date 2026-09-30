class_name DemoMainMenu
extends DemoScreen
## Main menu built with bdg_retro_menu. Emits mode_chosen; the parent decides
## what to mount.

signal mode_chosen(mode: int)

enum Mode { NEW_CAMPAIGN, LOAD_SAVEGAME, SKIRMISH, SETTINGS, QUIT }

var _title := ""
var _menu: RetroMenu
var _items: RetroMenuItem


func bind_dependencies(title: String) -> void:
	_title = title


func build() -> void:
	super.build()
	_menu = RetroMenu.new()
	_menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_menu.panel_origin = Vector2(64, 96)
	_menu.close_on_activate = false
	_menu.item_activated.connect(
		func(item: RetroMenuItem) -> void: mode_chosen.emit(item.id)
	)
	# Backing out of the top level must not leave an empty screen.
	_menu.closed.connect(func() -> void: _menu.open(_items))
	screen.add_child(_menu)

	_items = RetroMenuItem.new("main")
	_items.add_item("New Campaign", Mode.NEW_CAMPAIGN)
	_items.add_item("Load Savegame", Mode.LOAD_SAVEGAME)
	_items.add_item("Skirmish", Mode.SKIRMISH)
	_items.add_item("Settings", Mode.SETTINGS)
	_items.add_item("Quit", Mode.QUIT)


func setup() -> void:
	var title := Label.new()
	title.text = _title
	title.position = Vector2(64, 48)
	screen.add_child(title)
	_menu.open(_items)
