extends StateMachine

class_name WanderState

export var min_wander_dist : float = 40.0
export var max_wander_dist : float = 70.0

#### BUILT-IN ####
func _ready() -> void:
	var __ = $Wait.connect("wait_time_finished", self, "_on_Wait_wait_time_finished")
	__ = owner.connect("move_path_finished", self, "_on_Enemy_move_path_finished")

#### LOGIC ####

func _generate_random_destination() -> Vector2:
	var angle = deg2rad(rand_range(0.0, 360.0))
	var direction = Vector2(sin(angle), cos(angle))
	var distance = rand_range(min_wander_dist, max_wander_dist)
	
	return owner.global_position + direction * distance

func _find_wander_destination() -> Vector2:
	var pos = _generate_random_destination()
	
	if owner.pathfinder != null:
		while !owner.pathfinder.is_position_valid(pos):
			_generate_random_destination()
			
	return pos

#### SIGNAL RESPONSES ####

func _on_Wait_wait_time_finished() -> void:
	var destination = _find_wander_destination()
	owner.update_move_path(destination)
	
	set_state("GoTo")

func _on_Enemy_move_path_finished() -> void:
	if is_current_state():
		set_state("Wait")
