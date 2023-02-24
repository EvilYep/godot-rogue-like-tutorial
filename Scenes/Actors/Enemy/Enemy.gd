extends Actor

class_name Enemy

onready var behaviour_tree = $BehaviourTree
onready var chase_area = $ChaseArea
onready var attack_area = $AttackArea

var target : Node2D = null

var target_in_chase_area : bool = false setget set_target_in_chase_area
var target_in_attack_area : bool = false setget set_target_in_attack_area

signal target_in_chase_area_changed
signal target_in_attack_area_changed


#### ACCESSORS ####

func set_target_in_chase_area(value: bool) -> void:
	if value != target_in_chase_area:
		target_in_chase_area = value
		emit_signal("target_in_chase_area_changed", target_in_chase_area)

func set_target_in_attack_area(value: bool) -> void:
	if value != target_in_attack_area:
		target_in_attack_area = value
		emit_signal("target_in_attack_area_changed", target_in_attack_area)

#### BUILT-IN ####

func _ready() -> void:
	var __ = chase_area.connect("body_entered", self, "_on_ChaseArea_body_entered")
	__ = chase_area.connect("body_exited", self, "_on_ChaseArea_body_exited")
	__ = attack_area.connect("body_entered", self, "_on_AttackArea_body_entered")
	__ = attack_area.connect("body_exited", self, "_on_AttackArea_body_exited")
	__ = connect("target_in_chase_area_changed", self, "_on_target_in_chase_area_changed")
	__ = connect("target_in_attack_area_changed", self, "_on_target_in_attack_area_changed")

#### LOGIC ####

func _update_target() -> void:
	if !target_in_attack_area && !target_in_chase_area:
		target = null

func _update_behaviour_state() ->void:
	if target_in_attack_area:
		behaviour_tree.set_state("Attack")
	elif target_in_chase_area:
		behaviour_tree.set_state("Chase")
	else:
		behaviour_tree.set_state("Wander")

#### SIGNAL RESPONSES ####

func _on_ChaseArea_body_entered(body: Node2D) -> void:
	if body is Player:
		set_target_in_chase_area(true)
		target = body

func _on_ChaseArea_body_exited(body: Node2D) -> void:
	if body is Player:
		set_target_in_chase_area(false)

func _on_AttackArea_body_entered(body: Node2D) -> void:
	if body is Player:
		set_target_in_attack_area(true)
		target = body

func _on_AttackArea_body_exited(body: Node2D) -> void:
	if body is Player:
		set_target_in_attack_area(false)

func _on_target_in_chase_area_changed(_value: bool) -> void:
	_update_target()
	_update_behaviour_state()

func _on_target_in_attack_area_changed(_value: bool) -> void:
	_update_target()
	_update_behaviour_state()

