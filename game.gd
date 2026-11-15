extends Node2D
@export var move_offset := Vector2(200, 0) 

@onready var game_over_panel = $UI/GameOver
# Distance and direction to move
@export var duration := 2.0 # Time in seconds to reach the end

	
func _unhandled_input(event: InputEvent) -> void:
	if event .is_action_pressed("quit"):
		get_tree().quit()

func show_game_over() -> void:
	game_over_panel.show()
	get_tree().paused = true


func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	get_tree().quit()
