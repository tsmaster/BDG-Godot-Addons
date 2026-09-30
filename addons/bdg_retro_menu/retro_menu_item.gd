class_name RetroMenuItem
extends Resource
## One entry in a RetroMenu. An item with children is a submenu.

enum Type {
	## Choosing it emits item_activated (or opens its children, if it has any).
	ACTION,
	## Choosing it flips `checked` and emits item_toggled. The menu stays open.
	CHECKBOX,
	## Choosing it selects it and clears the other RADIO siblings in the same
	## `group`. Emits item_toggled only if the selection changed. The menu
	## stays open.
	RADIO,
}

@export var text := ""
@export var type := Type.ACTION
## State of a CHECKBOX or RADIO item. Read it any time, or set it before
## opening the menu. For radios, prefer select_radio() so the rest of the
## group is cleared.
@export var checked := false
## Radio group. RADIO items with the same group under the same parent are
## mutually exclusive. An enum member from your own game works well here too.
@export var group := 0
## Identifies the item in the item_activated signal. An enum member from your
## own game works well: enum values are ints, so
## `add_item("Attack", Action.ATTACK)` can be matched later with
## `match item.id: Action.ATTACK: ...`.
@export var id := -1
## Anything your game wants to carry with the item, such as a spell resource
## or an inventory slot. The menu never reads it.
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


## Appends a checkbox child and returns it.
func add_checkbox(
	p_text: String, p_checked := false, p_id := -1
) -> RetroMenuItem:
	var item := add_item(p_text, p_id)
	item.type = Type.CHECKBOX
	item.checked = p_checked
	return item


## Appends a radio child and returns it. If `p_checked` is true it becomes the
## selected item of its group.
func add_radio(
	p_text: String, p_group: int, p_checked := false, p_id := -1
) -> RetroMenuItem:
	var item := add_item(p_text, p_id)
	item.type = Type.RADIO
	item.group = p_group
	if p_checked:
		select_radio(item)
	return item


## Makes `radio` (one of this item's children) the selected item of its group
## and clears the other radios in that group.
func select_radio(radio: RetroMenuItem) -> void:
	for child in children:
		if child.type == Type.RADIO and child.group == radio.group:
			child.checked = child == radio


## The selected radio child of `p_group`, or null if none is selected.
func get_selected_radio(p_group: int) -> RetroMenuItem:
	for child in children:
		if (
			child.type == Type.RADIO
			and child.group == p_group
			and child.checked
		):
			return child
	return null


## Appends a child that is meant to hold its own children.
func add_submenu(
	p_text: String, p_columns := 1, p_max_visible_rows := 0
) -> RetroMenuItem:
	var item := add_item(p_text)
	item.columns = p_columns
	item.max_visible_rows = p_max_visible_rows
	return item
