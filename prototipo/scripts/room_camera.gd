class_name RoomCamera
extends Camera3D

@export var max_pan_degrees: Vector2 = Vector2(4.0, 2.5)
@export_range(0.1, 30.0, 0.1) var pan_response: float = 14.0

var _base_rotation: Vector3
var _target_pan: Vector2 = Vector2.ZERO
var _current_pan: Vector2 = Vector2.ZERO
var _mouse_inside: bool = true


func _ready() -> void:
	_base_rotation = rotation
	get_window().mouse_entered.connect(_on_mouse_entered)
	get_window().mouse_exited.connect(_on_mouse_exited)
	get_window().focus_entered.connect(_on_mouse_entered)
	get_window().focus_exited.connect(_on_mouse_exited)
	set_process(false)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and _mouse_inside:
		var viewport_size := get_viewport().get_visible_rect().size
		if viewport_size.x > 0.0 and viewport_size.y > 0.0:
			if not Rect2(Vector2.ZERO, viewport_size).has_point(event.position):
				_on_mouse_exited()
				return
			_target_pan = (event.position / viewport_size * 2.0 - Vector2.ONE).clamp(
				-Vector2.ONE, Vector2.ONE
			)
			set_process(true)


func _process(delta: float) -> void:
	_current_pan = _current_pan.lerp(_target_pan, 1.0 - exp(-pan_response * delta))
	if _current_pan.distance_squared_to(_target_pan) < 0.000001:
		_current_pan = _target_pan
		set_process(false)
	rotation = _base_rotation + Vector3(
		deg_to_rad(-_current_pan.y * max_pan_degrees.y),
		deg_to_rad(-_current_pan.x * max_pan_degrees.x),
		0.0
	)


func _on_mouse_entered() -> void:
	_mouse_inside = true


func _on_mouse_exited() -> void:
	_mouse_inside = false
	_target_pan = Vector2.ZERO
	set_process(true)
