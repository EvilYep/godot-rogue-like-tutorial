extends Label

class_name StateLabel

func _ready() -> void:
	yield(get_parent(), "ready")
	var __ = get_parent().connect("state_changed_recursive", self, "_on_StateMachine_state_changed_recursive")
	_update_text(get_parent().current_state)

func _update_text(state: Node) -> void:
	set_text(get_state_name_recursive(state))

func get_state_name_recursive(state: Node) -> String:
	if state is StateMachine:
		return state.name + " -> " + get_state_name_recursive(state.get_state())
	else:
		if state == null:
			return ""
		else:
			return state.name

func _on_StateMachine_state_changed_recursive(state: Node) -> void:
	_update_text(state)
