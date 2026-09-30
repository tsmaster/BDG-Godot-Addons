class_name DemoModeStub
extends DemoScreen
## Placeholder for a game mode. Shows what it was given and goes back on cancel.

signal back_requested

var _title := ""
var _settings: DemoSettings
var _label: Label


func bind_dependencies(title: String, settings: DemoSettings) -> void:
	_title = title
	_settings = settings


func build() -> void:
	super.build()
	_label = Label.new()
	_label.position = Vector2(64, 64)
	screen.add_child(_label)


func setup() -> void:
	_label.text = (
		(
			"%s (placeholder)\n\nMusic: %s   Sound: %s   Difficulty: %s\n\n"
			% [
				_title,
				"on" if _settings.music_on else "off",
				"on" if _settings.sound_on else "off",
				DemoSettings.Difficulty.find_key(_settings.difficulty),
			]
		)
		+ "Press Esc or B to return to the menu."
	)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		back_requested.emit()
