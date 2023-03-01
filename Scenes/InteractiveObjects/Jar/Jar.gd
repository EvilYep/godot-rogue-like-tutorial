extends StaticBody2D

onready var state_machine = $StateMachine
onready var animated_sprite = $AnimatedSprite
onready var collision_shape = $CollisionShape2D

func destroy() -> void:
	if state_machine.get_state_name() != "Idle":
		return
	
	EVENTS.emit_signal("obstacle_destroyed", self)
	
	state_machine.set_state("Breaking")
	animated_sprite.play("Break")
	$DropperBehaviour.drop_item()

func _on_AnimatedSprite_animation_finished() -> void:
	if animated_sprite.get_animation() == "Break":
		state_machine.set_state("Broken")
		collision_shape.set_disabled(true)
