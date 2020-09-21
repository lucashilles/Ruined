extends Area2D

func _on_Potion_body_entered(_body):
	PlayerStats.refill_ammo(5)
	queue_free()
