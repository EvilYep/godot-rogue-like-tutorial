extends Node2D

class_name Coin

onready var particles = $Particles2D
onready var coin_sprite = $CoinSprite
onready var shadow_sprite = $ShadowSprite
onready var animation_player = $AnimationPlayer

####  ACCESSORS  ####

#### BUILT-IN ####

func _ready() -> void:
	animation_player.play("Wave")

#### LOGIC ####

#### SIGNAL RESPONSES ####

func _on_Timer_timeout() -> void:
	if $CollectableBehaviour.state_machine.get_state_name() == "Idle":
		coin_sprite.play("Rotation")
		shadow_sprite.play("Rotation")

func _on_CoinSprite_animation_finished() -> void:
	if coin_sprite.get_animation() == "Rotation":
		coin_sprite.play("Idle")
		shadow_sprite.play("Idle")


