extends Node

@export var computer: Computer
@export var pc_shot: CameraShot


func _ready() -> void:
	Story.flag_changed.connect(_on_flag_changed)


func _on_flag_changed(flag: StringName, value: bool) -> void:
	if not value:
		return
	match flag:
		&"pc_hacked":
			Cutscene.play(_hacked)


func _hacked() -> void:
	await Cutscene.glitch(1.2)
	await Cutscene.cut(pc_shot)
	computer.set_powered(false)
	await Cutscene.wait(1.0)
	await Cutscene.say("", "(...what just happened?)")
	await Cutscene.release_camera()
