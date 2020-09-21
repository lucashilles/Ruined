extends KinematicBody2D

export (PackedScene) var Arrow

const MAX_SPEED = 100

enum {
	MOVE,
	ATTACK
}

var state = MOVE
var velocity = Vector2.ZERO

onready var animationPlayer = $AnimationPlayer
onready var apAttack = $AP_Attack
onready var hurtBox = $Hurtbox
onready var melee = $Melee
onready var ranged = $Ranged

func _ready():
# warning-ignore:return_value_discarded
	PlayerStats.connect("no_health", self, "queue_free")

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		
		ATTACK:
			attack_state()
	
	if PlayerStats.ranged:
		ranged.look_at(get_global_mouse_position())

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		velocity = input_vector * delta * MAX_SPEED
		if input_vector.x > 0:
			animationPlayer.play("RunRight")
		else:
			animationPlayer.play("RunLeft")
	else:
		velocity = Vector2.ZERO
		animationPlayer.play("Idle")
	
# warning-ignore:return_value_discarded
	move_and_collide(velocity)
	
	$Shield.visible = false
	$Shield/CollisionShape2D.disabled = true
	
	if Input.is_action_pressed("shield"):
		$Shield.visible = true
		$Shield.look_at(get_global_mouse_position())
		$Shield/CollisionShape2D.disabled = false
		ranged.visible = false
	else:
		ranged.visible = PlayerStats.ranged
		if Input.is_action_just_pressed("toogle_ranged"):
			PlayerStats.ranged = !PlayerStats.ranged
		
		if Input.is_action_just_pressed("attack"):
			if (!PlayerStats.ranged && PlayerStats.stamina > 10) || (PlayerStats.ranged && PlayerStats.arrows > 0):
				state = ATTACK
				if !PlayerStats.ranged:
					PlayerStats.action(10)
					melee.look_at(get_global_mouse_position())
				else:
					PlayerStats.shoot()

func attack_state():
	animationPlayer.play("Idle")
	if PlayerStats.ranged:
		shoot()
	else:
		apAttack.play("Attack")
		melee.visible = true

func shoot():
	var a = Arrow.instance()
	owner.add_child(a)
	a.transform = $Ranged/Aim.global_transform
	state = MOVE
	pass

func attack_animation_finished():
	melee.visible = false
	state = MOVE

func _on_Hurtbox_area_entered(area):
	PlayerStats.took_damage(area.damage)
	$ShaderPlayer.play("Hurt")
	hurtBox.start_invincibility(1)
