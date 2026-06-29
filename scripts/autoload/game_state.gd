extends Node

## Global game state singleton.
##
## Add state variables as needed, e.g.:
## var current_level: String = ""
## var score: int = 0

signal pause_toggled(paused: bool)

const RESOLUTIONS: Dictionary = {
	"1280x720": Vector2i(1280, 720),
	"1600x900": Vector2i(1600, 900),
	"1920x1080": Vector2i(1920, 1080),
	"2560x1440": Vector2i(2560, 1440),
}

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS

func set_window_size(width: int, height: int) -> void:
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(width, height))

func set_resolution(key: String) -> void:
	if RESOLUTIONS.has(key):
		var size: Vector2i = RESOLUTIONS[key]
		set_window_size(size.x, size.y)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		var paused := not get_tree().paused
		get_tree().paused = paused
		pause_toggled.emit(paused)
