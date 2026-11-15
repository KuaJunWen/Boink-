extends Node

@onready var health = $"../UI/Panel/health"
@onready var bossHealth = $"../UI/Panel2/boss"

var points = 0

func add_point():
	points += 1
	print(points)
	health.text = "Points : " + str(points)

func add_point2():
	points += 1
	print(points)
	bossHealth.text = "Points : " + str(points)
