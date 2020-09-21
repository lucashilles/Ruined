extends Node2D

onready var timer = $Timer

func _ready():
	timer.start(2)


func _on_Timer_timeout():
	queue_free()
