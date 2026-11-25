extends Camera3D

@export var max_pan_degrees: Vector2 = Vector2(4.0, 2.5)
@export_range(0.1, 30.0, 0.1) var pan_response: float = 14.0

var _base_rotation: Vector3
var _target_pan: Vector2 = Vector2.ZERO
var _current_pan: Vector2 = Vector2.ZERO


func _ready() -> void:
	_base_rotation = rotation
	get_window().mouse_exited.connect(_recenter)
	get_window().focus_exited.connect(_recenter)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and get_window().has_focus():
		var pan: Vector2 = event.position / get_viewport().get_visible_rect().size * 2.0 - Vector2.ONE
		_target_pan = pan if absf(pan.x) <= 1.0 and absf(pan.y) <= 1.0 else Vector2.ZERO


func _process(delta: float) -> void:
	_current_pan = _current_pan.lerp(_target_pan, 1.0 - exp(-pan_response * delta))
	rotation = _base_rotation + Vector3(
		deg_to_rad(-_current_pan.y * max_pan_degrees.y),
		deg_to_rad(-_current_pan.x * max_pan_degrees.x),
		0.0
	)


func _recenter() -> void:
	_target_pan = Vector2.ZERO
