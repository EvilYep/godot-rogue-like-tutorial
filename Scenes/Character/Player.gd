extends KinematicBody2D

var speed : float = 300.0
var direction = Vector2.ZERO

func _ready():
	pass # Replace with function body.

func _process(delta: float) -> void:
	move_and_slide(direction * speed)

func _input(event: InputEvent) -> void:
	direction.x = int(event.is_action_pressed("ui_right")) - int(event.is_action_pressed("ui_left"))
	direction.y = int(event.is_action_pressed("ui_down")) - int(event.is_action_pressed("ui_up"))

