extends CharacterBody2D

const SPEED = 300.0
const BOUNCE_VELOCITY = -450.0
@onready var sprite_2d = $player
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	
	velocity.y += gravity * delta
	if is_on_floor():
		velocity.y = BOUNCE_VELOCITY
		 
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, 12)
	move_and_slide()
