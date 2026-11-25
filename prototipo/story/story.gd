extends Node

signal flag_changed(flag: StringName, value: bool)
signal act_changed(act: int)

var act: int = 1:
	set(value):
		if value != act:
			act = value
			act_changed.emit(act)

var _flags: Dictionary[StringName, bool] = {}


func has_flag(flag: StringName) -> bool:
	return _flags.has(flag)


func set_flag(flag: StringName, value: bool = true) -> void:
	if has_flag(flag) == value:
		return
	if value:
		_flags[flag] = true
	else:
		_flags.erase(flag)
	flag_changed.emit(flag, value)


func clear_flag(flag: StringName) -> void:
	set_flag(flag, false)


func flags() -> Array[StringName]:
	return _flags.keys()


func reset() -> void:
	for flag in flags():
		clear_flag(flag)
	act = 1
