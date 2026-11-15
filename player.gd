extends CharacterBody2D

const SPEED = 300.0
const BOUNCE_VELOCITY = -450.0
const JUMP_VELOCITY = -450.0

const MAX_HEALTH = 100
const MAX_BOSSHEALTH = 100
const KNOCKBACK_SPEED = 500.0
const SLOW_DURATION = 1.0
const SLOW_MULTIPLIER = 0.5

const MIN_SPAWN_TIME = 2.5
const MAX_SPAWN_TIME = 7.0
const MIN_DISTANCE_FROM_PLAYER = 120.0

const PICKUP_SCENE = preload("res://attack_orb.tscn")

var health = MAX_HEALTH
var bossHealth = MAX_BOSSHEALTH
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var can_double_jump = false
var is_slowed = false
var is_game_over = false
var current_orb: Node2D = null  # Tracks the currently active orb

@onready var health_label = get_node_or_null("../UI/Panel/health")
@onready var bossHealth_label = get_node_or_null("../UI/Panel2/boss")

@onready var game_over_panel = get_node_or_null("../UI/GameOverPanel")
@onready var result_label = get_node_or_null("../UI/GameOverPanel/ResultLabel")
@onready var restart_button = get_node_or_null("../UI/GameOverPanel/RestartButton")

@onready var slow_timer = Timer.new()
@onready var spawn_timer = Timer.new()


func _ready() -> void:
	randomize()
	get_tree().paused = false

	slow_timer.one_shot = true
	slow_timer.timeout.connect(_on_slow_timer_timeout)
	add_child(slow_timer)

	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	_start_random_spawn_timer()
		

	_update_health_label()
	_update_bosshealth_label()


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


func _start_random_spawn_timer() -> void:
	var random_delay = randf_range(MIN_SPAWN_TIME, MAX_SPAWN_TIME)
	spawn_timer.start(random_delay)


func _on_spawn_timer_timeout() -> void:
	if is_game_over:
		return

	# Remove the previous orb if it hasn't been collected yet
	if is_instance_valid(current_orb):
		current_orb.queue_free()

	var pickup = PICKUP_SCENE.instantiate()
	var screen_size = get_viewport_rect().size
	var min_y = screen_size.y * 0.5         # Halfway down the screen (highest point)
	var max_y = screen_size.y - 60.0        # Near the bottom of the screen (with padding)
	var spawn_pos = Vector2.ZERO

	# Pick a random spot in the lower half of the screen away from the player
	for i in range(10):
		spawn_pos = Vector2(
			randf_range(60.0, screen_size.x - 60.0),
			randf_range(min_y, max_y)
		)
		if spawn_pos.distance_to(global_position) >= MIN_DISTANCE_FROM_PLAYER:
			break

	pickup.global_position = spawn_pos
	get_parent().add_child(pickup)
	current_orb = pickup

	_start_random_spawn_timer()


func damage_boss(amount: int) -> void:
	if is_game_over:
		return

	bossHealth = max(bossHealth - amount, 0)
	_update_bosshealth_label()


func take_hit(damage: int, hit_from: Vector2) -> void:
	if is_game_over:
		return

	health = max(health - damage, 0)
	_update_health_label()
 

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
