extends KinematicBody2D

class_name Actor

onready var state_machine = $StateMachine
onready var animated_sprite = $AnimatedSprite
onready var attack_hit_box = $AttackHitBox
onready var tween = $Tween

var dir_dict : Dictionary = {
	"Left" : Vector2.LEFT,
	"Right" : Vector2.RIGHT,
	"Up" : Vector2.UP,
	"Down" : Vector2.DOWN
}

export var speed : float = 300.0
var moving_direction := Vector2.ZERO setget set_moving_direction, get_moving_direction
var facing_direction := Vector2.DOWN setget set_facing_direction, get_facing_direction

export var max_hp : int = 3
onready var hp : int = max_hp setget set_hp, get_hp

signal facing_direction_changed
signal moving_direction_changed
signal hp_changed(hp)
signal death_feedback_finished

####  ACCESSORS  ####

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

func set_hp(value: int) -> void:
	value = Maths.clampi(value, 0, max_hp)
	
	if hp != value:
		hp = value
		emit_signal("hp_changed", hp)
func get_hp() -> int: return hp

#### BUILT-IN ####

func _ready() -> void:
	var __ = state_machine.connect("state_changed", self, "_on_state_changed")
	__ = connect("facing_direction_changed", self, "_on_facing_direction_changed")
	__ = connect("moving_direction_changed", self, "_on_moving_direction_changed")
	__ = animated_sprite.connect("animation_finished", self, "_on_AnimatedSprite_animation_finished")
	__ = animated_sprite.connect("frame_changed", self,  "_on_AnimatedSprite_frame_changed")
	__ = connect("hp_changed", self, "_on_hp_changed")
	__ = connect("death_feedback_finished", self, "_on_death_feedback_finished")

#### LOGIC ####

# Update animation based on current state and facing direction
func _update_animation() -> void:
	var direction = _find_dir_name(facing_direction)
	var state_name = state_machine.get_state_name()
	
	animated_sprite.play(state_name + direction)

# Find the name of a given direction and returns it as a String
func _find_dir_name(dir: Vector2) -> String:
	var dir_values_array = dir_dict.values()
	var index = dir_values_array.find(dir)
	if index == -1 : 
		return "Down"
	var dir_keys_array = dir_dict.keys()
	var dir_key = dir_keys_array[index]
	return dir_key

func _attack_effect() -> void:
	var bodies_array = attack_hit_box.get_overlapping_bodies()
	for body in bodies_array:
		if body == self:
			continue
		
		if body.has_method("hit"):
			body.face_position(global_position)
			var damage = _compute_damage(body)
			body.hit(damage)
		
		elif body.has_method("destroy"):
			body.destroy()

#update rotation of the attack hitbox based on the facing direction
func _update_attack_hitbox_direction() -> void:
	var angle = facing_direction.angle()
	attack_hit_box.set_rotation_degrees(rad2deg(angle) - 90)

func hit(damage: int) -> void:
	if state_machine.get_state_name() == "Block":
		parry()
	else:
		_hurt(damage)

func parry() -> void:
	state_machine.set_state("Parry")

func _hurt(damage: int) -> void:
	set_hp(hp - damage)
	state_machine.set_state("Hurt")
	_hurt_feedback()

func die() -> void:
	EVENTS.emit_signal("actor_died", self)
	state_machine.set_state("Dead")
	death_feedback()
	$CollisionShape2D.set_disabled(true)

func _hurt_feedback() -> void:
	tween.interpolate_property(animated_sprite.material, "shader_param/opacity", 0.0, 1.0, 0.1)
	tween.start()
	
	yield(tween, "tween_all_completed")
	
	tween.interpolate_property(animated_sprite.material, "shader_param/opacity", 1.0, 0.0, 0.1)
	tween.start()

func death_feedback() -> void:
	tween.interpolate_property(self, "modulate:a", 1.0, 0.0, 0.8)
	tween.start()
	
	yield(tween, "tween_all_completed")
	emit_signal("death_feedback_finished")

func _compute_damage(_target: Actor) -> int:
	return 1

func face_position(pos: Vector2) -> void:
	var dir = global_position.direction_to(pos)
	face_direction(dir)

func face_direction(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		set_facing_direction(Vector2(sign(dir.x), 0))
	else:
		set_facing_direction(Vector2(0, sign(dir.y)))

####  SIGNAL RESPONSES  ####

func _on_hp_changed(_new_hp: int) -> void:
	pass

func _on_state_changed(_new_state: Object) -> void:
	_update_animation()

func _on_AnimatedSprite_animation_finished() -> void:
	if "Attack".is_subsequence_of(animated_sprite.get_animation()):
		state_machine.set_state("Idle")
	elif "Parry".is_subsequence_of(animated_sprite.get_animation()):
		state_machine.set_state("Block")
	elif "Hurt".is_subsequence_of(animated_sprite.get_animation()):
		if hp == 0:
			die()
		else:
			state_machine.set_state("Idle")

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

func _on_death_feedback_finished() -> void:
	queue_free()
