extends Node2D

onready var particles = $Particles2D
onready var audio_stream = $AudioStreamPlayer2D
onready var coin_sprite = $CoinSprite
onready var shadow_sprite = $ShadowSprite
onready var animation_player = $AnimationPlayer

enum STATE {
	SPAWN,
	IDLE,
	FOLLOW,
	COLLECT
}

const GRAVITY := 40.0
var speed : float = 400.0
var state : int = STATE.SPAWN setget set_state, get_state
var target : Node2D = null
var spawn_dir := Vector2.ZERO
var spawn_v_force : float = -400.0
var spawn_dir_force : float = 200.0
var spawn_dir_velocity := Vector2.ZERO
var damping := 20.0
signal state_changed

####  ACCESSORS  ####

func set_state(value: int) -> void:
	if value != state:
		state = value
		emit_signal("state_changed")

func get_state() -> int: return state

#### BUILT-IN ####

func _ready() -> void:
	animation_player.play("Wave")
	_init_spawn_values()

func _physics_process(delta: float) -> void:
	match(state):
		STATE.FOLLOW : _follow(delta)
		STATE.SPAWN : _spawn(delta)

#### LOGIC ####

func _follow(delta: float) -> void:
	if target == null:
		return
	
	var target_pos = target.get_position()
	var dist = position.distance_to(target_pos)
	var spd = speed * delta
	
	if dist < spd:
		position = target_pos
		if state == STATE.FOLLOW:
			collect()
	else:
		position = position.move_toward(target_pos, spd)

func _spawn(delta: float) -> void:
	spawn_v_force += GRAVITY
	var spawn_v_velocity = Vector2(0, spawn_v_force)
	spawn_dir_velocity = spawn_dir * spawn_dir_force
	spawn_dir_velocity = spawn_dir_velocity.limit_length(spawn_dir_velocity.length() - damping)
	
	var velocity =  spawn_v_velocity + spawn_dir_velocity
	position += velocity * delta

func _init_spawn_values() -> void:
	var rdm_angle = rand_range(0.0, 360.0)
	spawn_dir = Vector2(sin(rdm_angle), cos(rdm_angle))

func collect() -> void:
	set_state(STATE.COLLECT)
	particles.set_emitting(true)
	audio_stream.play()
	
	coin_sprite.set_visible(false)
	shadow_sprite.set_visible(false)
	
	EVENTS.emit_signal("coin_collected")
	
	yield(audio_stream, "finished")
	
	queue_free()

func _follow_target(tar: Node2D) -> void:
	set_state(STATE.FOLLOW)
	target = tar

#### SIGNAL RESPONSES ####

func _on_Area2D_body_entered(body: Node) -> void:
	if state == STATE.IDLE:
		_follow_target(body)
		animation_player.stop()

func _on_Timer_timeout() -> void:
	if state == STATE.IDLE:
		coin_sprite.play("Rotation")
		shadow_sprite.play("Rotation")


func _on_CoinSprite_animation_finished() -> void:
	if coin_sprite.get_animation() == "Rotation":
		coin_sprite.play("Idle")
		shadow_sprite.play("Idle")


func _on_SpawnDurationTimer_timeout() -> void:
	set_state(STATE.IDLE)


func _on_Coin_state_changed() -> void:
	if state == STATE.IDLE:
		for body in $Area2D.get_overlapping_bodies():
			if body is Player:
				_follow_target(body)
