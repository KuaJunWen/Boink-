extends CharacterBody2D

const SPEED = 300.0
const BOUNCE_VELOCITY = -450.0
const JUMP_VELOCITY = -450.0

const MAX_HEALTH = 100
const KNOCKBACK_SPEED = 500.0
const SLOW_DURATION = 1.0
const SLOW_MULTIPLIER = 0.5

var health = MAX_HEALTH
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var can_double_jump = false
var is_slowed = false

@onready var health_label = get_node_or_null("../UI/Panel/health")
@onready var slow_timer = Timer.new()


func _ready() -> void:
	# This timer ends the one-second slow effect.
	slow_timer.one_shot = true
	slow_timer.timeout.connect(_on_slow_timer_timeout)
	add_child(slow_timer)
	_update_health_label()


func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta

	if is_on_floor():
		$AnimatedSprite2D.play("default")
		velocity.y = BOUNCE_VELOCITY
		can_double_jump = true
	elif Input.is_action_just_pressed("ui_accept") and can_double_jump:
		$AnimatedSprite2D.play("default")
		velocity.y = JUMP_VELOCITY
		can_double_jump = false

	var direction = Input.get_axis("left", "right")
	var current_speed = SPEED

	if is_slowed:
		current_speed *= SLOW_MULTIPLIER

	if direction:
		velocity.x = direction * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, 12)

	move_and_slide()


func take_hit(damage: int, hit_from: Vector2) -> void:
	health = max(health - damage, 0)
	_update_health_label()

	# Push the player away from the thing that hit them.
	var direction = (global_position - hit_from).normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.UP

	velocity = direction * KNOCKBACK_SPEED

	# Halve movement speed for one second.
	is_slowed = true
	slow_timer.start(SLOW_DURATION)


func _on_slow_timer_timeout() -> void:
	is_slowed = false


func _update_health_label() -> void:
	if health_label:
		health_label.text = "HEALTH : " + str(health)
