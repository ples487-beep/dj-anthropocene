class_name InteractionPrompt
extends CanvasLayer

const MOVE_ACTIONS: Array[StringName] = [&"move_left", &"move_right", &"move_forward", &"move_backward"]

var _panel: PanelContainer
var _label: Label


func _init() -> void:
	layer = 5

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.0, 0.0, 0.6)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(10)
	style.content_margin_left = 16
	style.content_margin_right = 16

	_panel = PanelContainer.new()
	_panel.add_theme_stylebox_override(&"panel", style)
	_panel.anchor_left = 0.5
	_panel.anchor_right = 0.5
	_panel.anchor_top = 1.0
	_panel.anchor_bottom = 1.0
	_panel.offset_bottom = -40
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_panel)

	_label = Label.new()
	_label.add_theme_font_size_override(&"font_size", 20)
	_panel.add_child(_label)
	_panel.hide()


func _process(_delta: float) -> void:
	var text := ""
	if not Dialogue.is_active():
		text = _current_prompt()
	_panel.visible = not text.is_empty()
	if _panel.visible:
		_label.text = "%s   %s" % [_key_name(), text]


func _current_prompt() -> String:
	if Interactable.current:
		return Interactable.current.back_prompt
	var target := _target()
	return target.prompt if target else ""


func _unhandled_input(event: InputEvent) -> void:
	if Dialogue.is_active():
		return
	var active := Interactable.current
	if active:
		if event.is_action_pressed(&"interact") or event.is_action_pressed(&"ui_cancel") or _is_move(event):
			get_viewport().set_input_as_handled()
			active.disengage()
	elif event.is_action_pressed(&"interact"):
		var target := _target()
		if target:
			get_viewport().set_input_as_handled()
			target.engage()


func _target() -> Interactable:
	var player := get_tree().get_first_node_in_group(&"player") as Node3D
	if not player:
		return null
	var best: Interactable
	var best_distance := INF
	for node in get_tree().get_nodes_in_group(&"interactable"):
		var candidate := node as Interactable
		if candidate and candidate.in_range():
			var distance := candidate.global_position.distance_squared_to(player.global_position)
			if distance < best_distance:
				best = candidate
				best_distance = distance
	return best


func _is_move(event: InputEvent) -> bool:
	for action in MOVE_ACTIONS:
		if event.is_action_pressed(action):
			return true
	return false


func _key_name() -> String:
	for event in InputMap.action_get_events(&"interact"):
		if event is InputEventKey:
			return event.as_text_physical_keycode()
	return "?"
