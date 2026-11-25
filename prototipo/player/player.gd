extends CharacterBody3D

@export var speed: float = 4.0

@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D

var _view: Basis
var _controllable: bool = true


func _ready() -> void:
	add_to_group(&"player")
	get_window().focus_exited.connect(_on_focus_exited)


func _physics_process(delta: float) -> void:
	var movement := Input.get_vector(
		&"move_left", &"move_right", &"move_forward", &"move_backward"
	)
	if not _controllable:
		movement = Vector2.ZERO
	if movement.is_zero_approx():
		_view = get_viewport().get_camera_3d().global_basis
	var right := Vector3(_view.x.x, 0.0, _view.x.z).normalized()
	var backward := Vector3(_view.z.x, 0.0, _view.z.z).normalized()
	var direction := right * movement.x + backward * movement.y
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()
	_update_sprite(movement)


func _update_sprite(movement: Vector2) -> void:
	if movement.is_zero_approx():
		sprite.stop()
		return

	var animation := sprite.animation
	if not is_zero_approx(movement.x):
		animation = &"walk_right" if movement.x > 0.0 else &"walk_left"
	if sprite.animation != animation or not sprite.is_playing():
		sprite.play(animation)


func set_controllable(value: bool) -> void:
	_controllable = value


func _on_focus_exited() -> void:
	for action in [&"move_left", &"move_right", &"move_forward", &"move_backward"]:
		Input.action_release(action)
