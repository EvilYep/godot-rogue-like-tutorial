extends Behaviour

class_name CollectableBehaviour

signal collected

onready var state_machine = $StateMachine
onready var animation_player = $AnimationPlayer

#### BUILT-IN ####

func _ready() -> void:
	var __ = $FollowArea.connect("body_entered", self, "_on_FollowArea_body_entered")
	__ = state_machine.connect("state_changed", self, "_on_StateMachine_state_changed")
	__ = animation_player.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")

#### LOGIC ####

func _follow_target(tar: Node2D) -> void:
	state_machine.set_state("Follow")
	$StateMachine/Follow.target = tar

func collect() -> void:
	state_machine.set_state("Collect")
	emit_signal("collected")
	EVENTS.emit_signal("object_collected", object)
	
	if animation_player.has_animation("Collect"):
		animation_player.play("Collect")
	else:
		queue_free()

#### SIGNAL RESPONSES ####

func _on_FollowArea_body_entered(body: Node) -> void:
	if state_machine.get_state_name() == "Idle":
		_follow_target(body)

func _on_StateMachine_state_changed(new_state: Node) -> void:
	if new_state.name == "Idle":
		for body in $FollowArea.get_overlapping_bodies():
			if body is Player:
				_follow_target(body)

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "Collect":
		object.queue_free()
