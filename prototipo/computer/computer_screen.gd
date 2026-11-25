class_name ComputerScreen
extends CanvasLayer

signal closed

const MARGIN := 40

var browser: CefTexture

var _hint: Label


func _init(cef: CefTexture) -> void:
	browser = cef
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS

	var backdrop := ColorRect.new()
	backdrop.color = Color(0.0, 0.0, 0.0, 0.85)
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)

	browser.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, MARGIN)
	browser.focus_mode = Control.FOCUS_ALL
	add_child(browser)

	_hint = Label.new()
	_hint.text = "Esc - close"
	_hint.position = Vector2(MARGIN, 10)
	add_child(_hint)


func _ready() -> void:
	_set_open(false)


func open() -> void:
	_set_open(true)
	browser.grab_focus()


func close() -> void:
	if visible:
		_set_open(false)
		closed.emit()


func _process(_delta: float) -> void:
	_hint.visible = not Web.close_locked
	if visible and not Web.close_locked and Input.is_action_just_pressed(&"ui_cancel"):
		close()


func _set_open(value: bool) -> void:
	visible = value
	get_tree().paused = value
