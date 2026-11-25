extends CanvasLayer

const GLITCH_SHADER := preload("res://fx/glitch.gdshader")

var _fade: ColorRect
var _glitch: ColorRect
var _glitch_material: ShaderMaterial
var _fade_tween: Tween
var _glitch_tween: Tween


func _init() -> void:
	layer = 15
	process_mode = Node.PROCESS_MODE_ALWAYS

	_glitch_material = ShaderMaterial.new()
	_glitch_material.shader = GLITCH_SHADER
	_glitch = ColorRect.new()
	_glitch.material = _glitch_material
	_glitch.set_anchors_preset(Control.PRESET_FULL_RECT)
	_glitch.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_glitch.hide()
	add_child(_glitch)

	_fade = ColorRect.new()
	_fade.color = Color(0.0, 0.0, 0.0, 0.0)
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fade)


func fade_out(duration: float = 0.6, color: Color = Color.BLACK) -> void:
	await _fade_to(Color(color, 1.0), duration)


func fade_in(duration: float = 0.6) -> void:
	await _fade_to(Color(_fade.color, 0.0), duration)


func flash(color: Color = Color.WHITE, duration: float = 0.4) -> void:
	_fade.color = Color(color, 1.0)
	await _fade_to(Color(color, 0.0), duration)


func glitch(duration: float = 0.6, strength: float = 1.0) -> void:
	if _glitch_tween:
		_glitch_tween.kill()
	_glitch.show()
	_glitch_tween = create_tween()
	_glitch_tween.tween_method(_set_glitch_strength, strength, 0.0, duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	await _glitch_tween.finished
	_glitch.hide()


func is_faded() -> bool:
	return _fade.color.a > 0.0


func clear() -> void:
	for tween in [_fade_tween, _glitch_tween]:
		if tween:
			tween.kill()
	_fade.color = Color(0.0, 0.0, 0.0, 0.0)
	_glitch.hide()


func _process(_delta: float) -> void:
	if _glitch.visible:
		_glitch_material.set_shader_parameter(&"seed", randf() * 100.0)


func _fade_to(target: Color, duration: float) -> void:
	if _fade_tween:
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(_fade, ^"color", target, duration)
	await _fade_tween.finished


func _set_glitch_strength(value: float) -> void:
	_glitch_material.set_shader_parameter(&"strength", value)
