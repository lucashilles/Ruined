extends KinematicBody2D

export (PackedScene) var fireball
export (PackedScene) var storm

const ACCELERATION = 300
const MAX_SPEED = 50

enum {
	CHASE,
	IDLE,
	ATTACK,
	WANDER
}

var direction
var rng = RandomNumberGenerator.new()
var state = IDLE
var stormPostion = Vector2.ZERO
var velocity = Vector2.ZERO

onready var animationPlayer = $AnimationPlayer
onready var hitbox = $Hitbox
onready var playerDetectionZone = $PlayerDetectionZone
onready var sprite = $Sprite
onready var softCollision = $SoftCollision
onready var stats = $Stats
onready var fbTimer = $FBTimer
onready var stormTimer = $StormTimer

func _ready():
	animationPlayer.play("Idle")
	self.add_to_group("miniboss")

func _physics_process(delta):
	match state:
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				direction = global_position.direction_to(player.global_position)
				velocity = velocity.move_toward(direction * MAX_SPEED, delta * ACCELERATION)
				animationPlayer.play("Walk")
				var distance = global_position.distance_to(playerDetectionZone.player.global_position)
				if fbTimer.is_stopped() && distance < 100:
					state = ATTACK
					velocity = Vector2.ZERO
					$Ranged.look_at(player.global_position)
					animationPlayer.play("Fireball")
				elif stormTimer.is_stopped():
					state = ATTACK
					velocity = Vector2.ZERO
					stormPostion = player.global_position
					animationPlayer.play("Storm")
				elif distance < 16.0 :
					state = ATTACK
					velocity = Vector2.ZERO
					animationPlayer.play("Melee")
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
		
	if state == ATTACK:
		sprite.flip_h = direction.x < 0
		if direction.x < 0:
			hitbox.scale.x = -1
		else:
			hitbox.scale.x = 1
	else:
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
	self.remove_from_group("miniboss")
	if !PlayerStats.has_key:
		if get_tree().get_nodes_in_group("miniboss").size() == 0:
			_drop_key()
		elif rng.randi_range(0, 100) <= 10:
			_drop_key()
	queue_free()

func _drop_key():
	var k = preload("res://Items/Key.tscn").instance()
	get_parent().call_deferred("add_child", k)
	k.global_position = global_position
	k.set_map_node(owner)

func shoot_fireball():
	if fbTimer.is_stopped():
		var f = fireball.instance()
		get_parent().call_deferred("add_child", f)
		f.transform = $Ranged/Aim.global_transform
		fbTimer.start(2)

func place_storm():
	if stormTimer.is_stopped():
		var s = storm.instance()
		get_parent().call_deferred("add_child", s)
		s.global_position = stormPostion
		s.get_node("AnimationPlayer").play("Puff")
		stormTimer.start(3)

func finish_attack():
	state = IDLE
