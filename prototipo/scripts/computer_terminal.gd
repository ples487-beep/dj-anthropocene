class_name ComputerTerminal
extends StaticBody3D

signal interact_requested
signal interaction_available_changed(available: bool)

var _player_nearby: bool = false


func _unhandled_input(event: InputEvent) -> void:
	if _player_nearby and event.is_action_pressed(&"interact") and not event.is_echo():
		get_viewport().set_input_as_handled()
		interact_requested.emit()


func is_player_nearby() -> bool:
	return _player_nearby


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_nearby = true
		interaction_available_changed.emit(true)


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_nearby = false
		interaction_available_changed.emit(false)
