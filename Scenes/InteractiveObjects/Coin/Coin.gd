extends Node2D

class_name Coin

onready var state_machine = $StateMachine
onready var particles = $Particles2D
onready var audio_stream = $AudioStreamPlayer2D
onready var coin_sprite = $CoinSprite
onready var shadow_sprite = $ShadowSprite
onready var animation_player = $AnimationPlayer

####  ACCESSORS  ####

#### BUILT-IN ####

func _ready() -> void:
	animation_player.play("Wave")

#### LOGIC ####

func collect() -> void:
	state_machine.set_state("Collect")
	particles.set_emitting(true)
	audio_stream.play()
	
	coin_sprite.set_visible(false)
	shadow_sprite.set_visible(false)
	
	EVENTS.emit_signal("coin_collected")
	
	yield(audio_stream, "finished")
	
	queue_free()

func _follow_target(tar: Node2D) -> void:
	state_machine.set_state("Follow")
	$StateMachine/Follow.target = tar

#### SIGNAL RESPONSES ####

func _on_Area2D_body_entered(body: Node) -> void:
	if state_machine.get_state_name() == "Idle":
		_follow_target(body)
		animation_player.stop()

func _on_Timer_timeout() -> void:
	if state_machine.get_state_name() == "Idle":
		coin_sprite.play("Rotation")
		shadow_sprite.play("Rotation")

func _on_CoinSprite_animation_finished() -> void:
	if coin_sprite.get_animation() == "Rotation":
		coin_sprite.play("Idle")
		shadow_sprite.play("Idle")

func _on_StateMachine_state_changed(new_state: Node) -> void:
	if new_state.name == "Idle":
		for body in $Area2D.get_overlapping_bodies():
			if body is Player:
				_follow_target(body)
