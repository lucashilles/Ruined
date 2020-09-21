extends Area2D

var mapNode

signal got_key

func set_map_node(node):
	mapNode = node
# warning-ignore:return_value_discarded
	connect("got_key", mapNode, "open_door")

func _on_Key_body_entered(_body):
	emit_signal("got_key")
	$AudioStreamPlayer.play()
	queue_free()
