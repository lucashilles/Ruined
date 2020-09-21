extends KinematicBody2D

export (Array, PackedScene) var Drops

export var ACCELERATION = 300
export var MAX_SPEED = 50

enum {
	CHASE,
	IDLE,
	ATTACK,
	WANDER
}

var cooldown = false
var dashDirection
var dropRate = [30, 20]
var rng = RandomNumberGenerator.new()
var state = IDLE
var velocity = Vector2.ZERO

onready var animationPlayer = $AnimationPlayer
onready var hitbox = $Hitbox
onready var hitboxCollisionShape = $Hitbox/CollisionShape2D
onready var playerDetectionZone = $PlayerDetectionZone
onready var softCollision = $SoftCollision
onready var sprite = $Sprite
onready var stats = $Stats
onready var timer = $Timer
onready var wanderController = $WanderController

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
				if global_position.distance_to(player.global_position) < 36.0 && !cooldown:
					state = ATTACK
					if global_position.direction_to(player.global_position).x < 0:
						hitbox.scale.x = -1.0
					else:
						hitbox.scale.x = 1.0
					dashDirection = hitboxCollisionShape.global_position.direction_to(player.global_position)
					animationPlayer.play("Attack")
					cooldown = true
					timer.start(3)
			else:
				state = IDLE
		
		IDLE:
			animationPlayer.play("Idle")
			velocity = Vector2.ZERO
			seek_player()
			if wanderController.get_time_left() == 0:
				state = pick_new_state([IDLE, WANDER])
				wanderController.set_wander_timer(rand_range(1, 3))
		
		ATTACK:
			velocity = velocity.move_toward(dashDirection * MAX_SPEED * 1.25, delta * ACCELERATION * 1.25)
		
		WANDER:
			animationPlayer.play("Walk")
			seek_player()
			if wanderController.get_time_left() == 0:
				state = pick_new_state([IDLE, WANDER])
				wanderController.set_wander_timer(rand_range(1, 5))
				
			var direction = global_position.direction_to(wanderController.target_posision)
			velocity = velocity.move_toward(direction * MAX_SPEED * 0.4, delta * ACCELERATION * 0.4)
	
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 600
	
	sprite.flip_h = velocity.x < 0
# warning-ignore:return_value_discarded
	move_and_slide(velocity)

func seek_player():
	if playerDetectionZone.player != null:
		state = CHASE

func pick_new_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_Hurtbox_area_entered(area):
	stats.took_damage(area.damage)
	$ShaderPlayer.play("Hurt")

func _on_Stats_no_health():
	if Drops.size() > 0:
		var roll = rng.randi_range(0, 100)
		var items = []
		
		for i in range(0, Drops.size()):
			if roll <= dropRate[i]:
				items.append(Drops[i])
		
		var drop
		if items.size() > 0:
			drop = items[rng.randi_range(0, items.size() - 1)].instance()
			drop.global_position = global_position
			get_parent().call_deferred("add_child", drop)
	
	queue_free()

func _on_Timer_timeout():
	cooldown = false

func finish_attack():
	state = IDLE
