class_name DemoBarrelChase
extends DemoMatchStub

var _settings: DemoSettings
var _barrels := 0


func bind_dependencies(settings: DemoSettings, barrels: int) -> void:
	_settings = settings
	_barrels = barrels


func _title() -> String:
	return "Barrel Chase"


func _details() -> String:
	return (
		"Barrels: %d   Music: %s"
		% [_barrels, "on" if _settings.music_on else "off"]
	)
