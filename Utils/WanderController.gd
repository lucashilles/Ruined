extends Node2D

export(int) var wander_range = 32

onready var start_position = global_position
onready var target_posision = global_position

onready var timer = $Timer

func update_target_position():
	var target_vector = Vector2(rand_range(-wander_range, wander_range), rand_range(-wander_range, wander_range))
	target_posision = start_position + target_vector

func get_time_left():
	return timer.time_left

func set_wander_timer(amount):
	timer.start(amount)

func _on_Timer_timeout():
	update_target_position()
