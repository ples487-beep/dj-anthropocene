class_name PlayerController
extends CharacterBody3D

@export var speed: float = 4.0

var controls_enabled: bool = true

@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D


func _ready() -> void:
	get_window().focus_exited.connect(_on_focus_exited)


func set_controls_enabled(enabled: bool) -> void:
	controls_enabled = enabled
	velocity = Vector3.ZERO
	if not enabled:
		sprite.stop()


func _physics_process(delta: float) -> void:
	if not controls_enabled:
		return

	var movement := Input.get_vector(
		&"move_left", &"move_right", &"move_forward", &"move_backward"
	)
	var direction := Vector3(movement.x, 0.0, movement.y)
	var camera := get_viewport().get_camera_3d()
	if camera != null:
		var right := camera.global_basis.x
		var backward := camera.global_basis.z
		right.y = 0.0
		backward.y = 0.0
		direction = right.normalized() * movement.x + backward.normalized() * movement.y
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()
	_update_sprite(movement)


func _update_sprite(movement: Vector2) -> void:
	if movement.is_zero_approx():
		if sprite.is_playing():
			sprite.stop()
		return

	var animation: StringName
	if absf(movement.x) > absf(movement.y):
		animation = &"direita" if movement.x > 0.0 else &"esquerda"
	else:
		animation = &"frente" if movement.y > 0.0 else &"tras"
	if sprite.animation != animation or not sprite.is_playing():
		sprite.play(animation)


func _on_focus_exited() -> void:
	velocity = Vector3.ZERO
	for action in [&"move_left", &"move_right", &"move_forward", &"move_backward"]:
		Input.action_release(action)
	sprite.stop()
