extends Node2D

var speed = 400

func _physics_process(delta):
	position += transform.x * speed * delta

func _on_Hitbox_body_entered(_body):
	queue_free()

func _on_Hitbox_area_entered(_area):
	queue_free()
