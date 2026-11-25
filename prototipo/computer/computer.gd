class_name Computer
extends StaticBody3D

@export var url: String = "res://sites/apocapedia/index.html"
@export var power_on_prompt: String = "Turn on computer"

var powered: bool = true

var _screen: ComputerScreen
var _monitor: StandardMaterial3D
var _use_prompt: String

@onready var _interactable: Interactable = $InteractionArea


func _ready() -> void:
	var browser := CefTexture.new()
	browser.enable_accelerated_osr = false
	browser.url = url
	Web.attach(browser)

	_screen = ComputerScreen.new(browser)
	add_child(_screen)
	_screen.closed.connect(_interactable.disengage)
	_interactable.engaged.connect(_on_engaged)
	_use_prompt = _interactable.prompt
	add_to_group(&"computer")

	_monitor = StandardMaterial3D.new()
	_monitor.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	$Screen.material_override = _monitor


func _process(_delta: float) -> void:
	var texture := _screen.browser.texture if powered else null
	if _monitor.albedo_texture != texture:
		_monitor.albedo_texture = texture
		_monitor.albedo_color = Color.WHITE if powered else Color(0.02, 0.02, 0.03)


func set_powered(value: bool) -> void:
	powered = value
	_screen.browser.browser_hidden = not value
	_interactable.prompt = _use_prompt if value else power_on_prompt
	if not value:
		close_screen()


func close_screen() -> void:
	_screen.close()
	_interactable.disengage()


func _on_engaged() -> void:
	if _interactable.shot:
		await get_tree().create_timer(_interactable.shot.blend_time).timeout
	if not _interactable.is_engaged():
		return
	if not powered:
		set_powered(true)
		await get_tree().create_timer(0.6).timeout
	if _interactable.is_engaged() and powered:
		_screen.open()
