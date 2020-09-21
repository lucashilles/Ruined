extends Area2D

var invincible = false setget set_invincible

signal invincibility_started
signal invincibility_ended

onready var collision = $CollisionShape2D
onready var timer = $Timer

func set_invincible(value):
	invincible = value
	if invincible:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")

func start_invincibility(duration):
	self.invincible = true
	collision.set_deferred("disabled", true)
	timer.start(duration)

func _on_Timer_timeout():
	self.invincible = false
	collision.disabled = false
