extends Area2D


func _on_Potion_body_entered(_body):
	PlayerStats.drink(15)
	queue_free()
