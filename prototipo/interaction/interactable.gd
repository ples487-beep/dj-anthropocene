class_name Interactable
extends Area3D

signal engaged
signal disengaged

static var current: Interactable

@export var prompt: String = "Interact"
@export var back_prompt: String = "Back"
@export var shot: CameraShot
@export var hold: bool = true
@export_multiline var lines: PackedStringArray
@export var requires_flag: StringName
@export var hidden_by_flag: StringName
@export var sets_flag: StringName


func _init() -> void:
	collision_layer = 0
	collision_mask = 2


func _ready() -> void:
	add_to_group(&"interactable")


func _exit_tree() -> void:
	if current == self:
		current = null


func is_available() -> bool:
	if not requires_flag.is_empty() and not Story.has_flag(requires_flag):
		return false
	if not hidden_by_flag.is_empty() and Story.has_flag(hidden_by_flag):
		return false
	return true


func in_range() -> bool:
	return monitoring and is_available() and has_overlapping_bodies()


func is_engaged() -> bool:
	return current == self


func engage() -> void:
	if not sets_flag.is_empty():
		Story.set_flag(sets_flag)
	if not hold:
		engaged.emit()
		await Dialogue.say_lines(lines)
		return
	if current:
		current.disengage()
	current = self
	var camera := _camera()
	if camera and shot:
		camera.play(shot)
	get_tree().call_group(&"player", &"set_input_lock", &"interaction", true)
	engaged.emit()
	if lines.is_empty():
		return
	if shot:
		await get_tree().create_timer(shot.blend_time).timeout
	if is_engaged():
		await Dialogue.say_lines(lines)


func disengage() -> void:
	if current != self:
		return
	current = null
	var camera := _camera()
	if camera and shot:
		camera.stop()
	get_tree().call_group(&"player", &"set_input_lock", &"interaction", false)
	disengaged.emit()


func _camera() -> RoomCamera:
	return get_viewport().get_camera_3d() as RoomCamera
