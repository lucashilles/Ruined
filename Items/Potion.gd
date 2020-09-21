extends Area2D

func _on_Potion_body_entered(_body):
	PlayerStats.heal(1)
	queue_free()
