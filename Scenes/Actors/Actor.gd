extends KinematicBody2D

class_name Actor

onready var animated_sprite = $AnimatedSprite
onready var attack_hit_box = $AttackHitBox

enum STATE {
	IDLE,
	MOVE,
	ATTACK
}

var dir_dict : Dictionary = {
	"Left" : Vector2.LEFT,
	"Right" : Vector2.RIGHT,
	"Up" : Vector2.UP,
	"Down" : Vector2.DOWN
}

var state : int = STATE.IDLE setget set_state, get_state
var speed : float = 300.0
var moving_direction := Vector2.ZERO setget set_moving_direction, get_moving_direction
var facing_direction := Vector2.DOWN setget set_facing_direction, get_facing_direction
signal state_changed
signal facing_direction_changed
signal moving_direction_changed

####  ACCESSORS  ####

func set_state(value: int) -> void:
	if value != state:
		state = value
		emit_signal("state_changed")

func get_state() -> int: return state

func set_facing_direction(value: Vector2) -> void:
	if facing_direction != value:
		facing_direction = value
		emit_signal("facing_direction_changed")

func get_facing_direction() -> Vector2: return facing_direction

func set_moving_direction(value: Vector2) -> void:
	if moving_direction != value:
		moving_direction = value
		emit_signal("moving_direction_changed")

func get_moving_direction() -> Vector2: return moving_direction

#### BUILT-IN ####

func _physics_process(_delta: float) -> void:
	var __ = move_and_slide(moving_direction * speed)

#### LOGIC ####

# Update animation based on current state and facing direction
func _update_animation() -> void:
	var direction = _find_dir_name(facing_direction)
	var state_name = ""
	
	match(state):
		STATE.IDLE: state_name = "Idle"
		STATE.MOVE: state_name = "Move"
		STATE.ATTACK: state_name = "Attack"
	
	animated_sprite.play(state_name + direction)

# Find the name of a given direction and returns it as a String
func _find_dir_name(dir: Vector2) -> String:
	var dir_values_array = dir_dict.values()
	var index = dir_values_array.find(dir)
	if index == -1 : 
		return ""
	var dir_keys_array = dir_dict.keys()
	var dir_key = dir_keys_array[index]
	return dir_key

func _attack_effect() -> void:
	var bodies_array = attack_hit_box.get_overlapping_bodies()
	for body in bodies_array:
		if body.has_method("destroy"):
			body.destroy()

#update rotation of the attack hitbox based on the facing direction
func _update_attack_hitbox_direction() -> void:
	var angle = facing_direction.angle()
	attack_hit_box.set_rotation_degrees(rad2deg(angle) - 90)

####  SIGNAL RESPONSES  ####
func _on_state_changed() -> void:
	_update_animation()

func _on_AnimatedSprite_animation_finished() -> void:
	if "Attack".is_subsequence_of(animated_sprite.get_animation()):
		set_state(STATE.IDLE)

func _on_facing_direction_changed() -> void:
	_update_animation()
	_update_attack_hitbox_direction()

func _on_moving_direction_changed() -> void:
	if moving_direction == Vector2.ZERO or moving_direction == facing_direction:
		return
	var sign_dir = Vector2(sign(moving_direction.x), sign(moving_direction.y))
	
	if sign_dir == moving_direction:
		set_facing_direction(moving_direction)
	else:
		if sign_dir.x == facing_direction.x:
			set_facing_direction(Vector2(0, sign_dir.y))
		else:
			set_facing_direction(Vector2(sign_dir.x, 0))

func _on_AnimatedSprite_frame_changed() -> void:
	if "Attack".is_subsequence_of(animated_sprite.get_animation()):
		if animated_sprite.get_frame() == 1:
			_attack_effect()
