extends StaticBody2D

func open_door():
	$Sprite.frame = 2
	get_node("CollisionShape2D").queue_free()
