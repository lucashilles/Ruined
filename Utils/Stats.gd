extends Node

export var max_health := 1
onready var health = max_health

signal no_health

func took_damage(value):
	health = health - value
	if health <= 0:
			emit_signal("no_health")
			
func heal(value):
	health = max(health + value, max_health)
