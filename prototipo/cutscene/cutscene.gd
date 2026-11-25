extends Node

signal started
signal finished

var _depth: int = 0


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func is_playing() -> bool:
	return _depth > 0


func play(steps: Callable) -> void:
	begin()
	await steps.call()
	end()


func begin() -> void:
	_depth += 1
	if _depth == 1:
		get_tree().call_group(&"player", &"set_input_lock", &"cutscene", true)
		started.emit()


func end() -> void:
	_depth = maxi(_depth - 1, 0)
	if _depth == 0:
		get_tree().call_group(&"player", &"set_input_lock", &"cutscene", false)
		finished.emit()


func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func shot(target: CameraShot, blend: float = -1.0) -> void:
	var camera := _camera()
	if not camera or not target:
		return
	camera.play(target, blend)
	await wait(blend if blend >= 0.0 else target.blend_time)


func cut(target: CameraShot) -> void:
	await shot(target, 0.0)


func release_camera(blend: float = -1.0) -> void:
	var camera := _camera()
	if not camera:
		return
	camera.stop(blend)
	await wait(blend if blend >= 0.0 else camera.shot.blend_time)


func say(speaker: String, text: String) -> void:
	await Dialogue.say(speaker, text)


func lines(entries: PackedStringArray) -> void:
	await Dialogue.say_lines(entries)


func choose(options: PackedStringArray, speaker: String = "", text: String = "") -> int:
	return await Dialogue.choose(options, speaker, text)


func flag(name: StringName, value: bool = true) -> void:
	Story.set_flag(name, value)


func fade_out(duration: float = 0.6, color: Color = Color.BLACK) -> void:
	await Fx.fade_out(duration, color)


func fade_in(duration: float = 0.6) -> void:
	await Fx.fade_in(duration)


func glitch(duration: float = 0.6, strength: float = 1.0) -> void:
	await Fx.glitch(duration, strength)


func _camera() -> RoomCamera:
	return get_viewport().get_camera_3d() as RoomCamera
