class_name CameraShot
extends Camera3D

@export var pan_degrees: Vector2 = Vector2(4.0, 2.5)
@export_range(0.0, 5.0, 0.05, "suffix:s") var blend_time: float = 0.6
@export var priority: int = 0
@export var hide_player: bool = false
