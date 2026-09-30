class_name DemoSettingsScreen
extends DemoScreen
## Settings screen using the retro menu's checkboxes and radio buttons. The
## items are created in setup() because they depend on the bound settings.

signal back_requested

enum Item { MUSIC, SOUND, EASY, NORMAL, HARD, BACK }
enum Group { DIFFICULTY }

var _settings: DemoSettings
var _menu: RetroMenu
var _items: RetroMenuItem


func bind_dependencies(settings: DemoSettings) -> void:
	_settings = settings


func build() -> void:
	super.build()
	_menu = RetroMenu.new()
	_menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_menu.panel_origin = Vector2(64, 96)
	_menu.close_on_activate = false
	_menu.item_toggled.connect(_on_item_toggled)
	_menu.item_activated.connect(
		func(_item: RetroMenuItem) -> void: back_requested.emit()
	)
	_menu.closed.connect(func() -> void: back_requested.emit())
	screen.add_child(_menu)


func setup() -> void:
	var difficulty := _settings.difficulty
	_items = RetroMenuItem.new("settings")
	_items.add_checkbox("Music", _settings.music_on, Item.MUSIC)
	_items.add_checkbox("Sound effects", _settings.sound_on, Item.SOUND)
	_items.add_radio(
		"Easy",
		Group.DIFFICULTY,
		difficulty == DemoSettings.Difficulty.EASY,
		Item.EASY
	)
	_items.add_radio(
		"Normal",
		Group.DIFFICULTY,
		difficulty == DemoSettings.Difficulty.NORMAL,
		Item.NORMAL
	)
	_items.add_radio(
		"Hard",
		Group.DIFFICULTY,
		difficulty == DemoSettings.Difficulty.HARD,
		Item.HARD
	)
	_items.add_item("Back", Item.BACK)
	_menu.open(_items)


func _on_item_toggled(item: RetroMenuItem) -> void:
	match item.id:
		Item.MUSIC:
			_settings.music_on = item.checked
		Item.SOUND:
			_settings.sound_on = item.checked
		Item.EASY:
			_settings.difficulty = DemoSettings.Difficulty.EASY
		Item.NORMAL:
			_settings.difficulty = DemoSettings.Difficulty.NORMAL
		Item.HARD:
			_settings.difficulty = DemoSettings.Difficulty.HARD
