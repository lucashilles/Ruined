extends Node

export var max_health := 1
export var max_stamina := 50
export var stamina_regen := 5
export var arrows := 5
export var has_key := false
onready var health = max_health
onready var stamina = max_stamina

var ranged = false

signal no_health

func _physics_process(delta):
	if stamina < max_stamina:
		stamina += stamina_regen * delta
		stamina = min(stamina, max_stamina)
		update_hud_stamina()

func restart():
	arrows = 5
	stamina = max_stamina
	health = max_health
	has_key = false

func took_damage(value):
	health = health - value
	update_hud_health()
	if health <= 0:
		emit_signal("no_health")

func heal(value):
	health = min(health + value, max_health)
	update_hud_health()

func action(value):
	stamina -= value

func drink(value):
	stamina = min(stamina + value, max_stamina)

func shoot():
	arrows -= 1
	update_hud_ammo()

func refill_ammo(value):
	arrows += value
	update_hud_ammo()

func update_hud_health():
	Hud.get_node("CanvasLayer/GUI/MarginContainer/VBoxContainer/Top/HP").text = "HP: " + str(health)

func update_hud_stamina():
	Hud.get_node("CanvasLayer/GUI/Stamina").value = int(stamina)

func update_hud_ammo():
	Hud.get_node("CanvasLayer/GUI/Arrows").text = "Arrows: " + str(arrows)

func update_hud_attack_type():
	pass
