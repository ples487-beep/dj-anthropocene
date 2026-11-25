class_name CameraZone
extends Area3D

@export var shot: CameraShot


func _init() -> void:
	collision_layer = 0
	collision_mask = 2


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _exit_tree() -> void:
	var camera := _camera()
	if camera:
		camera.release(shot)


func _on_body_entered(_body: Node3D) -> void:
	var camera := _camera()
	if camera:
		camera.request(shot)


func _on_body_exited(_body: Node3D) -> void:
	var camera := _camera()
	if camera:
		camera.release(shot)


func _camera() -> RoomCamera:
	return get_viewport().get_camera_3d() as RoomCamera
