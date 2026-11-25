class_name ComputerScreen
extends CanvasLayer

const MARGIN := 40

var _browser: CefTexture


func _init(browser: CefTexture) -> void:
	_browser = browser
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS

	var backdrop := ColorRect.new()
	backdrop.color = Color(0.0, 0.0, 0.0, 0.85)
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)

	_browser.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, MARGIN)
	_browser.focus_mode = Control.FOCUS_ALL
	add_child(_browser)

	var hint := Label.new()
	hint.text = "Esc - close"
	hint.position = Vector2(MARGIN, 10)
	add_child(hint)


func _ready() -> void:
	_set_open(false)


func open() -> void:
	_set_open(true)
	_browser.grab_focus()


func _process(_delta: float) -> void:
	if visible and Input.is_action_just_pressed(&"ui_cancel"):
		_set_open(false)


func _set_open(value: bool) -> void:
	visible = value
	_browser.browser_hidden = not value
	get_tree().paused = value
