extends KinematicBody2D

onready var animated_sprite = $AnimatedSprite

var dir_dict : Dictionary = {
	"Left" : Vector2.LEFT,
	"Right" : Vector2.RIGHT,
	"Up" : Vector2.UP,
	"Down" : Vector2.DOWN
}
var speed : float = 300.0
var moving_direction := Vector2.ZERO
var facing_direction := Vector2.DOWN
var is_attacking : bool = false
var is_moving : bool = false

func _ready(): 
	pass

func _process(_delta: float) -> void:
	var __ = move_and_slide(moving_direction * speed)
	# to get rid of the warning

func _input(_event: InputEvent) -> void:
	moving_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	moving_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	
	if moving_direction != Vector2.ZERO:
		facing_direction = moving_direction
	
	moving_direction = moving_direction.normalized()
	
	if Input.is_action_just_pressed("ui_accept"):
		is_attacking = true
	
	var direction = _find_moving_direction(facing_direction)
		
	if is_attacking:
		# Attack animation
		var anim_name = "Attack" + direction
		if animated_sprite.get_sprite_frames().has_animation(anim_name):
			animated_sprite.play(anim_name)
	else:
		# Idle animation
		if moving_direction == Vector2.ZERO:
			animated_sprite.stop()
			animated_sprite.set_frame(0)
		else:
			# Move animation
			is_moving = true
			var anim_name = "Move" + direction
			if animated_sprite.get_sprite_frames().has_animation(anim_name):
				animated_sprite.play(anim_name)

func _find_moving_direction(dir: Vector2) -> String:
	var dir_values_array = dir_dict.values()
	var index = dir_values_array.find(dir)
	if index == -1 : 
		return ""
	var dir_keys_array = dir_dict.keys()
	var dir_key = dir_keys_array[index]
	return dir_key


func _on_AnimatedSprite_animation_finished() -> void:
	if "Attack".is_subsequence_of(animated_sprite.get_animation()):
		is_attacking = false
		var direction = _find_moving_direction(facing_direction)
		animated_sprite.set_animation("Move" + direction)
		animated_sprite.stop()
		animated_sprite.set_frame(0)
