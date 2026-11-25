class_name Interactable
extends Area3D

signal engaged
signal disengaged

static var current: Interactable

@export var prompt: String = "Interact"
@export var back_prompt: String = "Back"
@export var shot: CameraShot
@export var hold: bool = true


func _init() -> void:
	collision_layer = 0
	collision_mask = 2


func _ready() -> void:
	add_to_group(&"interactable")


func _exit_tree() -> void:
	if current == self:
		current = null


func in_range() -> bool:
	return monitoring and has_overlapping_bodies()


func is_engaged() -> bool:
	return current == self


func engage() -> void:
	if not hold:
		engaged.emit()
		return
	if current:
		current.disengage()
	current = self
	var camera := _camera()
	if camera and shot:
		camera.play(shot)
	get_tree().call_group(&"player", &"set_controllable", false)
	engaged.emit()


func disengage() -> void:
	if current != self:
		return
	current = null
	var camera := _camera()
	if camera and shot:
		camera.stop()
	get_tree().call_group(&"player", &"set_controllable", true)
	disengaged.emit()


func _camera() -> RoomCamera:
	return get_viewport().get_camera_3d() as RoomCamera
