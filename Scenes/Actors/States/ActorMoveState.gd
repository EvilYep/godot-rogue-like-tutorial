extends State

class_name ActorMoveState

func update(_delta: float) -> void:
	var __ = owner.move_and_slide(owner.moving_direction * owner.speed)
