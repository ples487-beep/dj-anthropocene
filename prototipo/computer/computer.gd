extends StaticBody3D

@export var url: String = "res://sites/apocapedia/index.html"
@export var monitor_resolution: Vector2i = Vector2i(1280, 690)

var _screen: ComputerScreen

@onready var _interactable: Interactable = $InteractionArea


func _ready() -> void:
	var monitor_texture: CefTexture2D = _configure(CefTexture2D.new())
	monitor_texture.texture_size = monitor_resolution
	var monitor_material := StandardMaterial3D.new()
	monitor_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	monitor_material.albedo_texture = monitor_texture
	$Screen.material_override = monitor_material

	_screen = ComputerScreen.new(_configure(CefTexture.new()))
	add_child(_screen)
	_screen.closed.connect(_interactable.disengage)
	_interactable.engaged.connect(_on_engaged)


func _on_engaged() -> void:
	if _interactable.shot:
		await get_tree().create_timer(_interactable.shot.blend_time).timeout
	if _interactable.is_engaged():
		_screen.open()


func _configure(browser: Variant) -> Variant:
	browser.enable_accelerated_osr = false
	browser.url = url
	return browser
