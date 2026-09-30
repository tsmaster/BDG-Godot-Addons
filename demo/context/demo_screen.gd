class_name DemoScreen
extends Context
## Base for the demo's screens: a context that owns one full-screen Control.
## Subclasses call super.build() and add their widgets to `screen`.

var screen: Control


func build() -> void:
	screen = Control.new()
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(screen)
