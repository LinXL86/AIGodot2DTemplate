extends CanvasLayer

## Overlay showing FPS and frame time during development.
## Hidden in release builds. Press F3 to toggle.

@export var toggle_key: Key = KEY_F3
@export var show_frame_time: bool = true
@export var font_size: int = 14
@export var font_color: Color = Color.LIME_GREEN

var _fps_label: Label

func _ready() -> void:
	visible = OS.is_debug_build()

	_fps_label = Label.new()
	_fps_label.position = Vector2(10, 10)
	_fps_label.add_theme_color_override("font_color", font_color)
	_fps_label.add_theme_font_size_override("font_size", font_size)
	add_child(_fps_label)

func _process(delta: float) -> void:
	var text := "FPS: %d" % Engine.get_frames_per_second()
	if show_frame_time:
		text += "  %.1fms" % (delta * 1000.0)
	_fps_label.text = text

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == toggle_key:
		visible = not visible
