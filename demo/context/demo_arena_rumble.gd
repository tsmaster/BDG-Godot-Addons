class_name DemoArenaRumble
extends DemoMatchStub

var _settings: DemoSettings


func bind_dependencies(settings: DemoSettings) -> void:
	_settings = settings


func _title() -> String:
	return "Arena Rumble"


func _details() -> String:
	return (
		"Difficulty: %s"
		% DemoSettings.Difficulty.find_key(_settings.difficulty)
	)
