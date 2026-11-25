class_name CutscenePlayer
extends AnimationPlayer

@export var cutscene: StringName
@export var trigger_flag: StringName
@export var once: bool = true

var _played: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Story.flag_changed.connect(_on_flag_changed)


func run(animation: StringName = cutscene) -> void:
	if once and _played:
		return
	_played = true
	Cutscene.begin()
	play(animation)
	await animation_finished
	Cutscene.end()


func say(speaker: String, text: String) -> void:
	pause()
	await Dialogue.say(speaker, text)
	play()


func shot(path: NodePath, blend: float = -1.0) -> void:
	var camera := get_viewport().get_camera_3d() as RoomCamera
	var target := get_node_or_null(path) as CameraShot
	if camera and target:
		camera.play(target, blend)


func release_camera(blend: float = -1.0) -> void:
	var camera := get_viewport().get_camera_3d() as RoomCamera
	if camera:
		camera.stop(blend)


func flag(name: StringName, value: bool = true) -> void:
	Story.set_flag(name, value)


func fade_out(duration: float = 0.6) -> void:
	Fx.fade_out(duration)


func fade_in(duration: float = 0.6) -> void:
	Fx.fade_in(duration)


func glitch(duration: float = 0.6) -> void:
	Fx.glitch(duration)


func _on_flag_changed(flag_name: StringName, value: bool) -> void:
	if value and not trigger_flag.is_empty() and flag_name == trigger_flag and not cutscene.is_empty():
		run()
