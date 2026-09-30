class_name RetroMenu
extends Control
## Old-school cascading panel menu.
##
## Build a tree of RetroMenuItem, call open(root), and listen for item_activated.
## Controlled with the ui_* input actions and the mouse.
##
## Styling comes from the theme type "RetroMenu". Supported entries:
##   styles:    panel (usually a StyleBoxTexture nine-patch), cursor
##   fonts:     font          font sizes: font_size
##   colors:    font_color, font_disabled_color, arrow_color
##   constants: item_padding, panel_offset_x, panel_offset_y
##     (the offset constants override the panel_offset property, so a Theme can
##     carry the cascade spacing that suits its font)
## Anything missing falls back to a built-in retro look.

## Emitted when a leaf item is chosen.
signal item_activated(item: RetroMenuItem)
## Emitted whenever the highlighted item changes.
signal cursor_moved(item: RetroMenuItem)
## Emitted after the menu closes, whether by choosing an item or backing out.
signal closed

const THEME_TYPE := &"RetroMenu"
const ARROW_WIDTH := 10.0

## Where the first panel's top-left corner sits, in this control's local space.
@export var panel_origin := Vector2(16, 16)
## Extra offset of each nested panel relative to its parent, for the cascade look.
## Overridden by the theme constants panel_offset_x / panel_offset_y when set.
@export var panel_offset := Vector2(16, 16)
## Up/down wraps from the last row to the first.
@export var wrap_around := true
## Close the whole menu once a leaf item is activated.
@export var close_on_activate := true

## Each entry: {item: RetroMenuItem, cursor: int, top_row: int}
var _panels: Array[Dictionary] = []
var _fallback_panel: StyleBox
var _fallback_cursor: StyleBox


func _init() -> void:
	focus_mode = Control.FOCUS_ALL
	visible = false


func is_open() -> bool:
	return not _panels.is_empty()


func open(root: RetroMenuItem) -> void:
	_panels.clear()
	_push_panel(root)
	visible = true
	grab_focus()
	queue_redraw()


func close() -> void:
	if _panels.is_empty():
		return
	_panels.clear()
	visible = false
	closed.emit()


## Closes the top panel; closes the whole menu if it was the last one.
func back() -> void:
	if _panels.size() <= 1:
		close()
		return
	_panels.pop_back()
	queue_redraw()


func current_item() -> RetroMenuItem:
	if _panels.is_empty():
		return null
	var panel: Dictionary = _panels.back()
	return _cursor_item(panel)


# --- input ---------------------------------------------------------------

func _gui_input(event: InputEvent) -> void:
	if _panels.is_empty():
		return
	if event is InputEventMouseMotion:
		var index := _cell_at(event.position)
		if index >= 0:
			_set_cursor(index)
	elif event is InputEventMouseButton and event.pressed:
		_handle_mouse_button(event)
	elif event.is_action_pressed(&"ui_up", true):
		_move_cursor(0, -1)
	elif event.is_action_pressed(&"ui_down", true):
		_move_cursor(0, 1)
	elif event.is_action_pressed(&"ui_left", true):
		if _columns(_panels.back()) > 1:
			_move_cursor(-1, 0)
		else:
			back()
	elif event.is_action_pressed(&"ui_right", true):
		if _columns(_panels.back()) > 1:
			_move_cursor(1, 0)
		else:
			_activate_current()
	elif event.is_action_pressed(&"ui_accept"):
		_activate_current()
	elif event.is_action_pressed(&"ui_cancel"):
		back()
	else:
		return
	accept_event()


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	match event.button_index:
		MOUSE_BUTTON_LEFT:
			var index := _cell_at(event.position)
			if index >= 0:
				_set_cursor(index)
				_activate_current()
			elif not _top_rect().has_point(event.position):
				back()
		MOUSE_BUTTON_RIGHT:
			back()
		MOUSE_BUTTON_WHEEL_UP:
			_scroll(-1)
		MOUSE_BUTTON_WHEEL_DOWN:
			_scroll(1)
	accept_event()


func _move_cursor(dx: int, dy: int) -> void:
	var panel: Dictionary = _panels.back()
	var count: int = panel.item.children.size()
	var cols := _columns(panel)
	var rows := _row_count(panel)
	var col: int = panel.cursor % cols + dx
	var row: int = panel.cursor / cols + dy
	col = clampi(col, 0, cols - 1)
	if wrap_around:
		row = posmod(row, rows)
	else:
		row = clampi(row, 0, rows - 1)
	# The last row may be only partly filled.
	_set_cursor(mini(row * cols + col, count - 1))


func _set_cursor(index: int) -> void:
	var panel: Dictionary = _panels.back()
	if index == panel.cursor:
		return
	panel.cursor = index
	_scroll_to_cursor(panel)
	queue_redraw()
	cursor_moved.emit(_cursor_item(panel))


func _scroll(delta_rows: int) -> void:
	var panel: Dictionary = _panels.back()
	panel.top_row = clampi(panel.top_row + delta_rows, 0, _row_count(panel) - _visible_rows(panel))
	queue_redraw()


func _scroll_to_cursor(panel: Dictionary) -> void:
	var row: int = panel.cursor / _columns(panel)
	var visible_rows := _visible_rows(panel)
	if row < panel.top_row:
		panel.top_row = row
	elif row >= panel.top_row + visible_rows:
		panel.top_row = row - visible_rows + 1


func _activate_current() -> void:
	var item := current_item()
	if item == null or not item.enabled:
		return
	if item.is_submenu():
		_push_panel(item)
		queue_redraw()
	else:
		item_activated.emit(item)
		if close_on_activate:
			close()


func _push_panel(item: RetroMenuItem) -> void:
	if item.children.is_empty():
		return
	_panels.append({"item": item, "cursor": 0, "top_row": 0})


# --- layout --------------------------------------------------------------

func _cursor_item(panel: Dictionary) -> RetroMenuItem:
	return panel.item.children[panel.cursor]


func _columns(panel: Dictionary) -> int:
	return maxi(1, panel.item.columns)


func _row_count(panel: Dictionary) -> int:
	return ceili(float(panel.item.children.size()) / _columns(panel))


func _visible_rows(panel: Dictionary) -> int:
	var rows := _row_count(panel)
	var limit: int = panel.item.max_visible_rows
	return rows if limit <= 0 else mini(rows, limit)


## Geometry of one panel: outer rect, where the cells start, and the cell size.
func _layout(panel_index: int) -> Dictionary:
	var panel: Dictionary = _panels[panel_index]
	var font := _font()
	var font_size := _font_size()
	var pad := get_theme_constant(&"item_padding", THEME_TYPE) if has_theme_constant(&"item_padding", THEME_TYPE) else 4
	var widest := 0.0
	for child: RetroMenuItem in panel.item.children:
		widest = maxf(widest, font.get_string_size(child.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x)
	var cell := Vector2(widest + pad * 2 + ARROW_WIDTH, font.get_height(font_size) + pad * 2)
	var style := _panel_style()
	var border := Vector2(style.get_margin(SIDE_LEFT), style.get_margin(SIDE_TOP))
	var content := Vector2(_columns(panel) * cell.x, _visible_rows(panel) * cell.y)
	var origin := panel_origin + _panel_offset() * panel_index
	return {
		"rect": Rect2(origin, content + border + Vector2(style.get_margin(SIDE_RIGHT), style.get_margin(SIDE_BOTTOM))),
		"content_origin": origin + border,
		"cell": cell,
		"pad": pad,
	}


func _top_rect() -> Rect2:
	return _layout(_panels.size() - 1).rect


## Index of the child of the top panel under the local point, or -1.
func _cell_at(point: Vector2) -> int:
	var panel: Dictionary = _panels.back()
	var layout := _layout(_panels.size() - 1)
	var local: Vector2 = point - layout.content_origin
	if local.x < 0 or local.y < 0:
		return -1
	var col := int(local.x / layout.cell.x)
	var row := int(local.y / layout.cell.y)
	if col >= _columns(panel) or row >= _visible_rows(panel):
		return -1
	var index: int = (row + panel.top_row) * _columns(panel) + col
	return index if index < panel.item.children.size() else -1


# --- drawing -------------------------------------------------------------

func _draw() -> void:
	for i in _panels.size():
		_draw_panel(i, i == _panels.size() - 1)


func _draw_panel(panel_index: int, is_top: bool) -> void:
	var panel: Dictionary = _panels[panel_index]
	var layout := _layout(panel_index)
	var font := _font()
	var font_size := _font_size()
	var cols := _columns(panel)
	var visible_rows := _visible_rows(panel)
	draw_style_box(_panel_style(), layout.rect)

	var children: Array[RetroMenuItem] = panel.item.children
	for row in visible_rows:
		for col in cols:
			var index: int = (row + panel.top_row) * cols + col
			if index >= children.size():
				break
			var child := children[index]
			var cell_pos: Vector2 = layout.content_origin + Vector2(col * layout.cell.x, row * layout.cell.y)
			if index == panel.cursor:
				draw_style_box(_cursor_style(), Rect2(cell_pos, layout.cell))
				# Dim the cursor on parent panels so the active panel stands out.
				if not is_top:
					draw_rect(Rect2(cell_pos, layout.cell), Color(0, 0, 0, 0.35))
			var color := _color(&"font_color" if child.enabled else &"font_disabled_color")
			var baseline := cell_pos + Vector2(layout.pad, layout.pad + font.get_ascent(font_size))
			draw_string(font, baseline, child.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
			if child.is_submenu():
				_draw_arrow(cell_pos + Vector2(layout.cell.x - ARROW_WIDTH, layout.cell.y * 0.5), Vector2.RIGHT)

	# Scroll indicators sit on the right edge of the panel.
	var edge_x: float = layout.rect.end.x - ARROW_WIDTH
	if panel.top_row > 0:
		_draw_arrow(Vector2(edge_x, layout.rect.position.y + 6), Vector2.UP)
	if panel.top_row + visible_rows < _row_count(panel):
		_draw_arrow(Vector2(edge_x, layout.rect.end.y - 6), Vector2.DOWN)


## Draws a small filled triangle centered on `center`, pointing along `direction`.
func _draw_arrow(center: Vector2, direction: Vector2) -> void:
	var side := direction.orthogonal()
	var points := PackedVector2Array([
		center + direction * 4.0,
		center - direction * 3.0 + side * 4.0,
		center - direction * 3.0 - side * 4.0,
	])
	draw_colored_polygon(points, _color(&"arrow_color"))


# --- theme lookups with built-in fallbacks -------------------------------

func _panel_offset() -> Vector2:
	var offset := panel_offset
	if has_theme_constant(&"panel_offset_x", THEME_TYPE):
		offset.x = get_theme_constant(&"panel_offset_x", THEME_TYPE)
	if has_theme_constant(&"panel_offset_y", THEME_TYPE):
		offset.y = get_theme_constant(&"panel_offset_y", THEME_TYPE)
	return offset


func _font() -> Font:
	if has_theme_font(&"font", THEME_TYPE):
		return get_theme_font(&"font", THEME_TYPE)
	return ThemeDB.fallback_font


func _font_size() -> int:
	if has_theme_font_size(&"font_size", THEME_TYPE):
		return get_theme_font_size(&"font_size", THEME_TYPE)
	return 16


func _color(color_name: StringName) -> Color:
	if has_theme_color(color_name, THEME_TYPE):
		return get_theme_color(color_name, THEME_TYPE)
	match color_name:
		&"font_disabled_color":
			return Color(0.4, 0.4, 0.45)
		&"arrow_color":
			return Color(1, 1, 0.6)
	return Color.WHITE


func _panel_style() -> StyleBox:
	if has_theme_stylebox(&"panel", THEME_TYPE):
		return get_theme_stylebox(&"panel", THEME_TYPE)
	if _fallback_panel == null:
		_fallback_panel = _make_fallback_panel()
	return _fallback_panel


func _cursor_style() -> StyleBox:
	if has_theme_stylebox(&"cursor", THEME_TYPE):
		return get_theme_stylebox(&"cursor", THEME_TYPE)
	if _fallback_cursor == null:
		var flat := StyleBoxFlat.new()
		flat.bg_color = Color(1, 1, 1, 0.25)
		_fallback_cursor = flat
	return _fallback_cursor


## A generated nine-patch: dark blue fill inside a light double border.
func _make_fallback_panel() -> StyleBox:
	const SIZE := 24
	var image := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.05, 0.08, 0.35))
	for i in SIZE:
		for depth in [0, 1, 3]:
			var edge := Color.WHITE if depth < 2 else Color(0.5, 0.55, 0.9)
			image.set_pixel(i, depth, edge)
			image.set_pixel(i, SIZE - 1 - depth, edge)
			image.set_pixel(depth, i, edge)
			image.set_pixel(SIZE - 1 - depth, i, edge)
	var style := StyleBoxTexture.new()
	style.texture = ImageTexture.create_from_image(image)
	style.set_texture_margin_all(8)
	style.set_content_margin_all(8)
	return style
