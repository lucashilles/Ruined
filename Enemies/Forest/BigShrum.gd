extends KinematicBody2D

const ACCELERATION = 300
const MAX_SPEED = 50

enum {
	CHASE,
	IDLE,
	ATTACK,
	WANDER
}

var cooldown = false
var velocity = Vector2.ZERO
var rng = RandomNumberGenerator.new()
var state = IDLE

onready var animationPlayer = $AnimationPlayer
onready var basePoints = $BasePoints
onready var sprite = $Sprite
onready var softCollision = $SoftCollision
onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var timer = $Timer

func _ready():
	animationPlayer.play("Idle")
	add_to_group("miniboss")

func _physics_process(delta):
	match state:
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				var direction = global_position.direction_to(player.global_position)
				velocity = velocity.move_toward(direction * MAX_SPEED, delta * ACCELERATION)
				animationPlayer.play("Walk")
				if global_position.distance_to(playerDetectionZone.player.global_position) < 32.0 && !cooldown:
					state = ATTACK
					velocity = Vector2.ZERO
					animationPlayer.play("Attack")
			else:
				state = IDLE
				animationPlayer.play("Idle")
				velocity = Vector2.ZERO
		
		IDLE:
			seek_player()
		
		WANDER:
			pass
	
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 600
	
	sprite.flip_h = velocity.x < 0
# warning-ignore:return_value_discarded
	move_and_slide(velocity)

func seek_player():
	if playerDetectionZone.player != null:
		state = CHASE

func _on_Hurtbox_area_entered(area):
	stats.took_damage(area.damage)
	$ShaderPlayer.play("Hurt")

func _on_Stats_no_health():
	remove_from_group("miniboss")
	if !PlayerStats.has_key:
		if get_tree().get_nodes_in_group("miniboss").size() == 0:
			_drop_key()
		elif rng.randi_range(0, 100) <= 100:
			_drop_key()
	queue_free()

func _drop_key():
	var k = preload("res://Items/Key.tscn").instance()
	get_parent().call_deferred("add_child", k)
	k.global_position = global_position
	k.set_map_node(owner)

func gas_cloud():
	if !cooldown:
		for p in basePoints.get_children():
			var ac = preload("res://Weapons/AcidCloud.tscn").instance()
			get_parent().call_deferred("add_child", ac)
			ac.global_position = p.global_position
			ac.get_node("AnimationPlayer").play("Puff")
		cooldown = true
		timer.start(3)

func _on_Timer_timeout():
	cooldown = false

func finish_attack():
	state = IDLE
