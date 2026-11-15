extends Node

@onready var health = $"../UI/Panel/health"

var points = 0

func add_point():
	points += 1
	print(points)
	health.text = "Points : " + str(points)
