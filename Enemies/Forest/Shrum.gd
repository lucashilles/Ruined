extends KinematicBody2D

export (Array, PackedScene) var Drops

export var ACCELERATION = 300
export var MAX_SPEED = 50

enum {
	CHASE,
	IDLE,
	WANDER
}

var drop_rate = [20, 10, 50]
var rng = RandomNumberGenerator.new()
var state = IDLE
var velocity = Vector2.ZERO

onready var animationPlayer = $AnimationPlayer
onready var sprite = $Sprite
onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var softCollision = $SoftCollision

func _ready():
	animationPlayer.play("Idle")
	rng.randomize()

func _physics_process(delta):
	match state:
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				var direction = global_position.direction_to(player.global_position)
				velocity = velocity.move_toward(direction * MAX_SPEED, delta * ACCELERATION)
				animationPlayer.play("Walk")
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
	if Drops.size() > 0:
		var roll = rng.randi_range(0, 100)
		var items = []
		
		for i in range(0, drop_rate.size()):
			if roll <= drop_rate[i]:
				items.append(Drops[i])
		
		var drop
		if items.size() > 0:
			drop = items[rng.randi_range(0, items.size() - 1)].instance()
			drop.global_position = global_position
			get_parent().call_deferred("add_child", drop)
	
	queue_free()

