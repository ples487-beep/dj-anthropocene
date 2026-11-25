class_name RoomCamera
extends Camera3D

signal shot_changed(shot: CameraShot)

@export var default_shot: CameraShot
@export_range(0.1, 30.0, 0.1) var pan_response: float = 14.0

var shot: CameraShot

var _requests: Array[CameraShot] = []
var _scripted: CameraShot
var _base: Transform3D
var _from: Transform3D
var _from_fov: float
var _pan_limits: Vector2
var _from_pan_limits: Vector2
var _blend_time: float = 0.0
var _elapsed: float = 0.0
var _target_pan: Vector2 = Vector2.ZERO
var _current_pan: Vector2 = Vector2.ZERO
var _player_hidden: bool = false


func _ready() -> void:
	make_current()
	if not default_shot:
		default_shot = CameraShot.new()
		default_shot.top_level = true
		default_shot.transform = global_transform
		default_shot.fov = fov
		add_child(default_shot)
	_base = global_transform
	_pan_limits = default_shot.pan_degrees
	get_window().mouse_exited.connect(_recenter)
	get_window().focus_exited.connect(_recenter)
	_switch(_pick(), 0.0)


func request(requested: CameraShot) -> void:
	if requested and requested not in _requests:
		_requests.append(requested)
		_refresh()


func release(released: CameraShot) -> void:
	_requests.erase(released)
	_refresh()


func play(scripted: CameraShot, blend: float = -1.0) -> void:
	_scripted = scripted
	_refresh(blend)


func cut(scripted: CameraShot) -> void:
	play(scripted, 0.0)


func stop(blend: float = -1.0) -> void:
	_scripted = null
	_refresh(blend)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and get_window().has_focus():
		var pan: Vector2 = event.position / get_viewport().get_visible_rect().size * 2.0 - Vector2.ONE
		_target_pan = pan if absf(pan.x) <= 1.0 and absf(pan.y) <= 1.0 else Vector2.ZERO


func _process(delta: float) -> void:
	if not is_instance_valid(shot):
		_refresh(0.0)
		return

	_elapsed += delta
	var t := 1.0 if _blend_time <= 0.0 else smoothstep(0.0, 1.0, minf(_elapsed / _blend_time, 1.0))
	_base = _from.interpolate_with(shot.global_transform, t)
	fov = lerpf(_from_fov, shot.fov, t)
	_pan_limits = _from_pan_limits.lerp(shot.pan_degrees, t)

	_current_pan = _current_pan.lerp(_target_pan, 1.0 - exp(-pan_response * delta))
	var yaw := deg_to_rad(-_current_pan.x * _pan_limits.x)
	var pitch := deg_to_rad(-_current_pan.y * _pan_limits.y)
	global_transform = Transform3D(
		Basis(Vector3.UP, yaw) * _base.basis * Basis(Vector3.RIGHT, pitch),
		_base.origin
	)
	_set_player_hidden(shot.hide_player and t >= 0.5)


func _pick() -> CameraShot:
	if is_instance_valid(_scripted):
		return _scripted
	var best := default_shot
	var best_priority := -(1 << 62)
	for candidate in _requests:
		if is_instance_valid(candidate) and candidate.priority >= best_priority:
			best = candidate
			best_priority = candidate.priority
	return best


func _refresh(blend: float = -1.0) -> void:
	var next := _pick()
	if next != shot:
		_switch(next, blend if blend >= 0.0 else next.blend_time)


func _switch(next: CameraShot, blend: float) -> void:
	shot = next
	_from = _base
	_from_fov = fov
	_from_pan_limits = _pan_limits
	_blend_time = blend
	_elapsed = 0.0
	shot_changed.emit(shot)


func _set_player_hidden(value: bool) -> void:
	if value != _player_hidden:
		_player_hidden = value
		get_tree().call_group(&"player", &"set_visible", not value)


func _recenter() -> void:
	_target_pan = Vector2.ZERO
