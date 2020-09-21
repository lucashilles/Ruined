extends Node2D

export (String, FILE, "*.tscn") var Next_Level: String

func _ready():
	Hud.visible = true
	PauseMenu.can_show = true
	var hpLabel = Hud.get_node("CanvasLayer/GUI/MarginContainer/VBoxContainer/Top/HP")
	hpLabel.text = "HP: " + str(PlayerStats.health)

func open_door():
	Game.emit_signal("ChangeScene", Next_Level)
