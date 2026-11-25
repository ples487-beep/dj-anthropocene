extends StaticBody3D

@export var url: String = "res://sites/apocapedia/index.html"
@export var monitor_resolution: Vector2i = Vector2i(1280, 690)

var _screen: ComputerScreen


func _ready() -> void:
	var monitor_texture: CefTexture2D = _configure(CefTexture2D.new())
	monitor_texture.texture_size = monitor_resolution
	var monitor_material := StandardMaterial3D.new()
	monitor_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	monitor_material.albedo_texture = monitor_texture
	$Screen.material_override = monitor_material

	_screen = ComputerScreen.new(_configure(CefTexture.new()))
	add_child(_screen)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"interact") and $InteractionArea.has_overlapping_bodies():
		get_viewport().set_input_as_handled()
		_screen.open()


func _configure(browser: Variant) -> Variant:
	browser.enable_accelerated_osr = false
	browser.url = url
	return browser
