class_name DemoSkirmishMenu
extends DemoScreen
## Lets the player pick a skirmish game mode. Emits choice_made, or
## back_requested from the Back item or by cancelling out of the menu.

signal choice_made(choice: int)
signal back_requested

enum Choice { ARENA_RUMBLE, BARREL_CHASE, BACK }

var _menu: RetroMenu
var _items: RetroMenuItem


func build() -> void:
	super.build()
	_menu = RetroMenu.new()
	_menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_menu.panel_origin = Vector2(64, 96)
	_menu.close_on_activate = false
	_menu.item_activated.connect(_on_item_activated)
	_menu.closed.connect(func() -> void: back_requested.emit())
	screen.add_child(_menu)

	_items = RetroMenuItem.new("skirmish")
	_items.add_item("Arena Rumble", Choice.ARENA_RUMBLE)
	_items.add_item("Barrel Chase", Choice.BARREL_CHASE)
	_items.add_item("Back", Choice.BACK)


func setup() -> void:
	var title := Label.new()
	title.text = "Skirmish"
	title.position = Vector2(64, 48)
	screen.add_child(title)
	_menu.open(_items)


func _on_item_activated(item: RetroMenuItem) -> void:
	if item.id == Choice.BACK:
		back_requested.emit()
	else:
		choice_made.emit(item.id)
