class_name DemoMatchStub
extends DemoScreen
## Base for the placeholder skirmish matches. Enter or A finishes the match
## (completed); Esc or B abandons it (aborted). Subclasses set the title and
## describe what they were given.

signal completed
signal aborted

var _label: Label


func build() -> void:
	super.build()
	_label = Label.new()
	_label.position = Vector2(64, 64)
	screen.add_child(_label)


func setup() -> void:
	_label.text = (
		"%s (placeholder)\n\n%s\n\n" % [_title(), _details()]
		+ "Press Enter or A to finish the match, Esc or B to abandon it."
	)


## Name shown at the top. Override in subclasses.
func _title() -> String:
	return "Match"


## What the match was given. Override in subclasses.
func _details() -> String:
	return ""


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_accept"):
		get_viewport().set_input_as_handled()
		completed.emit()
	elif event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		aborted.emit()
