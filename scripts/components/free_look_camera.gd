extends Camera3D

## 自由视角 3D 调试摄像机。
##
## 右击捕获鼠标 → WASD 移动 + 鼠标环顾
## 滚轮调节移动速度
## Esc 释放鼠标
## 手柄右摇杆环顾

var _speed: float = 5.0

const MIN_SPEED: float = 1.0
const MAX_SPEED: float = 50.0
const MOUSE_SENSITIVITY: float = 0.002
const JOYSTICK_SENSITIVITY: float = 2.0

func _ready() -> void:
	look_at(Vector3.ZERO)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_RIGHT \
			and event.pressed:
		_toggle_mouse_capture()

	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				_speed = clampf(_speed * 1.1, MIN_SPEED, MAX_SPEED)
			MOUSE_BUTTON_WHEEL_DOWN:
				_speed = clampf(_speed / 1.1, MIN_SPEED, MAX_SPEED)

	if event is InputEventMouseMotion \
			and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		var x_rot: float = rotation.x - event.relative.y * MOUSE_SENSITIVITY
		rotation.x = clampf(x_rot, -deg_to_rad(90.0), deg_to_rad(90.0))

func _process(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := Vector3(input_dir.x, 0.0, input_dir.y)
	if direction.length() > 0.0:
		direction = (transform.basis * direction).normalized()

	var look_input := Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if look_input != Vector2.ZERO:
		rotate_y(-look_input.x * JOYSTICK_SENSITIVITY * delta)
		var x_rot: float = rotation.x - look_input.y * JOYSTICK_SENSITIVITY * delta
		rotation.x = clampf(x_rot, -deg_to_rad(90.0), deg_to_rad(90.0))

	position += direction * _speed * delta

func _toggle_mouse_capture() -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
