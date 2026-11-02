extends CharacterBody3D

@export var speed = 4.0

@onready var sprite = $AnimatedSprite3D
# mexe 

func _physics_process(delta):
	var input = Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
        "move_backward"
	)

	velocity.x = input.x * speed
	velocity.z = input.y * speed
	
# sprites
	if input.y < 0:
		sprite.play("tras")
	elif input.y > 0:
		sprite.play("frente")
	elif input.x < 0:
		sprite.play("esquerda")
	elif input.x > 0:
		sprite.play("direita")

	move_and_slide()
