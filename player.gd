extends CharacterBody2D

const SPEED = 300.0
const BOUNCE_VELOCITY = -450.0
const JUMP_VELOCITY = -450.0

const MAX_HEALTH = 100
const MAX_BOSSHEALTH = 100
const KNOCKBACK_SPEED = 500.0
const SLOW_DURATION = 1.0
const SLOW_MULTIPLIER = 0.5
const ATTACK_COOLDOWN = 10.0

var health = MAX_HEALTH
var bossHealth = MAX_BOSSHEALTH
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var can_double_jump = false
var is_slowed = false
var can_attack = true

@onready var health_label = get_node_or_null("../UI/Panel/health")
@onready var bossHealth_label = get_node_or_null("../UI/Panel2/boss")
@onready var cooldown_label = get_node_or_null("../UI/Panel3/cooldown") # Update path if inside a Panel
@onready var slow_timer = Timer.new()
@onready var attack_timer = Timer.new()


func _ready() -> void:
	slow_timer.one_shot = true
	slow_timer.timeout.connect(_on_slow_timer_timeout)
	add_child(slow_timer)

	attack_timer.one_shot = true
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	add_child(attack_timer)

	_update_health_label()
	_update_bosshealth_label()
	_update_cooldown_label()


func _process(_delta: float) -> void:
	# Continuously update the cooldown label while the timer is running
	if not can_attack:
		_update_cooldown_label()


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


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F and can_attack:
			damage_boss(5)
			can_attack = false
			attack_timer.start(ATTACK_COOLDOWN)


func _on_attack_timer_timeout() -> void:
	can_attack = true
	_update_cooldown_label()


func damage_boss(amount: int) -> void:
	bossHealth = max(bossHealth - amount, 0)
	_update_bosshealth_label()


func take_hit(damage: int, hit_from: Vector2) -> void:
	health = max(health - damage, 0)
	_update_health_label()
	if health == 0 :
		get_tree().paused = true
		$"../ColorRect".show()
		$"../Label".show()
	else : 
		var direction = (global_position - hit_from).normalized()
		if direction == Vector2.ZERO:
			direction = Vector2.UP

		velocity = direction * KNOCKBACK_SPEED

		is_slowed = true
		slow_timer.start(SLOW_DURATION)
	


func _on_slow_timer_timeout() -> void:
	is_slowed = false


func _update_health_label() -> void:
	if health_label:
		health_label.text = "HEALTH : " + str(health)
		
func _update_bosshealth_label() -> void:
	if bossHealth_label:
		bossHealth_label.text = "BOSS HEALTH : " + str(bossHealth)

func _update_cooldown_label() -> void:
	if cooldown_label:
		if can_attack:
			cooldown_label.text = "ATTACK: READY"
		else:
			# "%.1f" formats the remaining time to 1 decimal place (e.g., 9.4s)
			cooldown_label.text = "COOLDOWN: %.1fs" % attack_timer.time_left
