extends CanvasLayer

signal started
signal finished
signal _advanced
signal _chosen(index: int)

const CHARACTERS_PER_SECOND := 45.0

var _box: PanelContainer
var _speaker: Label
var _text: Label
var _choices: VBoxContainer
var _depth: int = 0
var _typing: bool = false
var _waiting: bool = false
var _shown: float = 0.0


func _init() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.05, 0.07, 0.88)
	style.border_color = Color(0.55, 0.86, 0.95, 0.6)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(18)
	style.content_margin_left = 24
	style.content_margin_right = 24

	_box = PanelContainer.new()
	_box.add_theme_stylebox_override(&"panel", style)
	_box.anchor_left = 0.15
	_box.anchor_right = 0.85
	_box.anchor_top = 1.0
	_box.anchor_bottom = 1.0
	_box.offset_bottom = -32
	_box.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_box.custom_minimum_size = Vector2(0, 120)
	add_child(_box)

	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", 8)
	_box.add_child(column)

	_speaker = Label.new()
	_speaker.add_theme_font_size_override(&"font_size", 20)
	_speaker.add_theme_color_override(&"font_color", Color(0.55, 0.86, 0.95))
	column.add_child(_speaker)

	_text = Label.new()
	_text.add_theme_font_size_override(&"font_size", 22)
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	column.add_child(_text)

	_choices = VBoxContainer.new()
	_choices.add_theme_constant_override(&"separation", 6)
	column.add_child(_choices)

	_box.hide()


func is_active() -> bool:
	return _depth > 0


func say(speaker: String, text: String) -> void:
	_begin()
	_show_line(speaker, text)
	_choices.hide()
	_shown = 0.0
	_text.visible_characters = 0
	_typing = true
	_waiting = true
	await _advanced
	_end()


func say_lines(lines: PackedStringArray) -> void:
	if lines.is_empty():
		return
	_begin()
	for line in lines:
		var parts := line.split(": ", true, 1)
		if parts.size() == 2 and not parts[0].contains(" "):
			await say(parts[0], parts[1])
		else:
			await say("", line)
	_end()


func choose(options: PackedStringArray, speaker: String = "", text: String = "") -> int:
	_begin()
	_show_line(speaker, text)
	_text.visible = not text.is_empty()
	_text.visible_characters = -1
	_typing = false
	_waiting = false
	for child in _choices.get_children():
		child.queue_free()
	for index in options.size():
		var button := Button.new()
		button.text = options[index]
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_font_size_override(&"font_size", 20)
		button.pressed.connect(_on_choice.bind(index))
		_choices.add_child(button)
	_choices.show()
	if _choices.get_child_count() > 0:
		(_choices.get_child(0) as Button).grab_focus.call_deferred()
	var picked: int = await _chosen
	_choices.hide()
	_text.visible = true
	_end()
	return picked


func _process(delta: float) -> void:
	if not _typing:
		return
	_shown += delta * CHARACTERS_PER_SECOND
	_text.visible_characters = int(_shown)
	if _shown >= _text.get_total_character_count():
		_finish_typing()


func _input(event: InputEvent) -> void:
	if not is_active():
		return
	if _choices.visible:
		if event.is_action_pressed(&"interact"):
			var focused := get_viewport().gui_get_focus_owner() as Button
			if focused and focused.get_parent() == _choices:
				get_viewport().set_input_as_handled()
				focused.pressed.emit()
		return
	if _is_advance(event):
		get_viewport().set_input_as_handled()
		if _typing:
			_finish_typing()
		elif _waiting:
			_waiting = false
			_advanced.emit()


func _is_advance(event: InputEvent) -> bool:
	if event.is_action_pressed(&"interact") or event.is_action_pressed(&"ui_accept"):
		return true
	var click := event as InputEventMouseButton
	return click != null and click.pressed and click.button_index == MOUSE_BUTTON_LEFT


func _show_line(speaker: String, text: String) -> void:
	_speaker.text = speaker
	_speaker.visible = not speaker.is_empty()
	_text.text = text
	_box.show()


func _on_choice(index: int) -> void:
	_chosen.emit(index)


func _finish_typing() -> void:
	_typing = false
	_text.visible_characters = -1


func _begin() -> void:
	_depth += 1
	if _depth == 1:
		get_tree().call_group(&"player", &"set_input_lock", &"dialogue", true)
		started.emit()


func _end() -> void:
	_depth -= 1
	if _depth == 0:
		_box.hide()
		_typing = false
		_waiting = false
		get_tree().call_group(&"player", &"set_input_lock", &"dialogue", false)
		finished.emit()
