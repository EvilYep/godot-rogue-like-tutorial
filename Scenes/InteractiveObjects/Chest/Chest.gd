extends StaticBody2D

onready var state_machine = $StateMachine
onready var animated_sprite = $AnimatedSprite
onready var collision_shape = $CollisionShape2D

var coin_scene = preload("res://Scenes/InteractiveObjects/Coin/Coin.tscn")

func interact() -> void:
	if state_machine.get_state_name() == "Idle":
		state_machine.set_state("Opening")
		animated_sprite.play("Open")

func _spawn_content() -> void:
	EVENTS.emit_signal("spawn_special_item", coin_scene, position)

func _on_AnimatedSprite_animation_finished() -> void:
	if animated_sprite.get_animation() == "Open":
		state_machine.set_state("Opened")
		_spawn_content()

