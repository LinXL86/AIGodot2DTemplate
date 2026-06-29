extends CanvasLayer

## FPS counter. Hidden in release builds.

var _fps_label: Label

func _ready() -> void:
	visible = OS.is_debug_build()

	_fps_label = Label.new()
	_fps_label.position = Vector2(10, 10)
	_fps_label.add_theme_color_override("font_color", Color.LIME_GREEN)
	_fps_label.add_theme_font_size_override("font_size", 14)
	add_child(_fps_label)

func _process(_delta: float) -> void:
	_fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
