extends Node

## Global game state singleton.
##
## Add state variables as needed, e.g.:
## var current_level: String = ""
## var score: int = 0
## var is_paused: bool = false

const RESOLUTIONS: Dictionary = {
	"1280x720": Vector2i(1280, 720),
	"1600x900": Vector2i(1600, 900),
	"1920x1080": Vector2i(1920, 1080),
	"2560x1440": Vector2i(2560, 1440),
}

func set_window_size(width: int, height: int) -> void:
	DisplayServer.window_set_size(Vector2i(width, height))

func set_resolution(key: String) -> void:
	if RESOLUTIONS.has(key):
		var size: Vector2i = RESOLUTIONS[key]
		DisplayServer.window_set_size(size)
