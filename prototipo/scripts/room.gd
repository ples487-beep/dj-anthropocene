class_name GameRoom
extends Node3D

signal computer_requested

@onready var player: PlayerController = $pessoa/PlayerD
@onready var computer: ComputerTerminal = $Computer


func _ready() -> void:
	computer.interact_requested.connect(computer_requested.emit)
