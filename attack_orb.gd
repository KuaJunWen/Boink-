extends Area2D

@export var damage_amount = 10


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	# Check if the colliding body is the player (has the damage_boss method)
	if body.has_method("damage_boss"):
		body.damage_boss(damage_amount)
		queue_free() # Remove the collected object
