extends Node

class_name State

# Abstract Class
func enter_state() -> void:
	pass

func exit_state() -> void:
	pass

func update(delta: float) -> void:
	pass