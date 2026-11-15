extends Node2D
@export var move_offset := Vector2(200, 0) # Distance and direction to move
@export var duration := 2.0 # Time in seconds to reach the end

	
func _unhandled_input(event: InputEvent) -> void:
	if event .is_action_pressed("quit"):
		get_tree().quit()
