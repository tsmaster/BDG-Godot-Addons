class_name RetroMenuItem
extends Resource
## One entry in a RetroMenu. An item with children is a submenu.

@export var text := ""
## Identifies the item in the item_activated signal. An enum member from your own
## game works well: enum values are ints, so `add_item("Attack", Action.ATTACK)`
## can be matched later with `match item.id: Action.ATTACK: ...`.
@export var id := -1
## Anything your game wants to carry with the item, such as a spell resource or an
## inventory slot. The menu never reads it.
@export var metadata: Variant = null
## Disabled items are drawn greyed out and cannot be activated.
@export var enabled := true
## Grid columns used when this item's children are shown as a panel.
@export_range(1, 16) var columns := 1
## Rows shown at once before the panel scrolls. 0 means show all rows.
@export_range(0, 64) var max_visible_rows := 0
@export var children: Array[RetroMenuItem] = []


func _init(p_text := "", p_id := -1) -> void:
	text = p_text
	id = p_id


func is_submenu() -> bool:
	return not children.is_empty()


## Appends a child and returns it, so calls can be nested.
func add_item(p_text: String, p_id := -1) -> RetroMenuItem:
	var item := RetroMenuItem.new(p_text, p_id)
	children.append(item)
	return item


## Appends a child that is meant to hold its own children.
func add_submenu(p_text: String, p_columns := 1, p_max_visible_rows := 0) -> RetroMenuItem:
	var item := add_item(p_text)
	item.columns = p_columns
	item.max_visible_rows = p_max_visible_rows
	return item
