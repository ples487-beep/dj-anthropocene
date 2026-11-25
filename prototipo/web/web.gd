extends Node

signal message_received(type: String, data: Variant)
signal page_loaded(url: String)
signal link_blocked(url: String)

const BRIDGE_PATH := "res://web/bridge.js"

var browser: CefTexture

var close_locked: bool = false:
	set(value):
		close_locked = value
		_push_state()

var navigation_locked: bool = false:
	set(value):
		navigation_locked = value
		_locked_url = _strip(current_url()) if value else ""
		_push_state()

var _locked_url: String = ""


func _ready() -> void:
	Story.flag_changed.connect(func(_flag: StringName, _value: bool) -> void: _push_state())
	Story.act_changed.connect(func(_act: int) -> void: _push_state())


func attach(target: CefTexture) -> void:
	browser = target
	browser.preload_script = FileAccess.get_file_as_string(BRIDGE_PATH)
	browser.ipc_message.connect(_on_ipc_message)
	browser.load_finished.connect(_on_load_finished)
	browser.url_changed.connect(_on_url_changed)


func current_url() -> String:
	return browser.url if browser else ""


func open(url: String) -> void:
	if browser:
		browser.url = url


func send(type: String, data: Variant = null) -> void:
	if browser:
		browser.send_ipc_message(JSON.stringify({"type": type, "data": data}))


func run(code: String) -> void:
	if browser:
		browser.eval(code)


func _push_state() -> void:
	send("state", {
		"act": Story.act,
		"flags": Story.flags(),
		"close_locked": close_locked,
		"navigation_locked": navigation_locked,
	})


func _on_ipc_message(raw: String) -> void:
	var parsed: Variant = JSON.parse_string(raw)
	var type := "message"
	var data: Variant = raw
	if parsed is Dictionary and parsed.has("type"):
		type = str(parsed["type"])
		data = parsed.get("data")

	match type:
		"flag":
			if data is Dictionary and data.has("name"):
				Story.set_flag(StringName(str(data["name"])), bool(data.get("value", true)))
		"link_blocked":
			link_blocked.emit(str(data))
		"glitch":
			var options: Dictionary = data if data is Dictionary else {}
			Fx.glitch(float(options.get("duration", 0.6)), float(options.get("strength", 1.0)))
	message_received.emit(type, data)


func _on_load_finished(url: String, _status: int) -> void:
	_push_state()
	page_loaded.emit(url)


func _on_url_changed(url: String) -> void:
	if navigation_locked and not _locked_url.is_empty() and _strip(url) != _locked_url:
		link_blocked.emit(url)
		browser.url = _locked_url


func _strip(url: String) -> String:
	return url.get_slice("#", 0)
