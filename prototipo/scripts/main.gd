extends Node

signal scene_changed(scene: Node)
signal computer_interacted

@onready var current_scene: Node = $Room


func _ready() -> void:
	Input.use_accumulated_input = false
	_connect_scene(current_scene)
	current_scene.reset_physics_interpolation()


func change_scene(scene: PackedScene) -> void:
	_replace_scene.call_deferred(scene)


func _replace_scene(scene: PackedScene) -> void:
	var next_scene := scene.instantiate()
	remove_child(current_scene)
	current_scene.queue_free()
	current_scene = next_scene
	add_child(current_scene)
	_connect_scene(current_scene)
	current_scene.reset_physics_interpolation()
	scene_changed.emit(current_scene)


func _connect_scene(scene: Node) -> void:
	if scene is GameRoom:
		scene.computer_requested.connect(_on_computer_requested)


func _on_computer_requested() -> void:
	computer_interacted.emit()
	print("Computer interacted")
