extends Node

class_name State

onready var state_machine = get_parent()

#### VIRTUAL ####

func enter_state() -> void:
	pass

func exit_state() -> void:
	pass

func update(_delta: float) -> void:
	pass

func is_current_state() -> bool:
	return state_machine.get_state() == self
