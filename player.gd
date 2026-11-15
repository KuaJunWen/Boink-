extends CharacterBody2D

const SPEED = 300.0
const BOUNCE_VELOCITY = -450.0
const JUMP_VELOCITY = -450

@onready var sprite_2d = $player
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var can_double_jump = false

func _physics_process(delta):
	velocity.y += gravity * delta
	
	if is_on_floor():
		$AnimatedSprite2D.play("default")
		velocity.y = BOUNCE_VELOCITY
		can_double_jump = true 
	elif Input.is_action_just_pressed("ui_accept") and can_double_jump:
		$AnimatedSprite2D.play("default")
		velocity.y = JUMP_VELOCITY
		can_double_jump = false # Consume the air jump
		
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, 12)
		
	move_and_slide()
