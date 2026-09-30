class_name DemoSplash
extends DemoScreen
## Loading screen. Its setup() awaits a fake loading sequence, so the parent's
## replace_child() does not return until loading has finished.

const STEPS := 20

var _seconds := 1.0
var _bar: ProgressBar


func bind_dependencies(seconds: float) -> void:
	_seconds = seconds


func build() -> void:
	super.build()
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.add_child(center)
	var box := VBoxContainer.new()
	center.add_child(box)
	var title := Label.new()
	title.text = "bdg_context demo"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	_bar = ProgressBar.new()
	_bar.custom_minimum_size = Vector2(320, 24)
	box.add_child(_bar)


func setup() -> void:
	for step in STEPS + 1:
		_bar.value = 100.0 * step / STEPS
		await get_tree().create_timer(_seconds / STEPS).timeout
