extends Node2D

class_name ItemFactory

var item_scene = preload("res://Scenes/InteractiveObjects/Item/Item.tscn")

#### BUILT-IN ####

func _ready() -> void:
	var __ = EVENTS.connect("spawn_special_item", self, "_on_EVENTS_spawn_special_item")
	__ = EVENTS.connect("spawn_item", self, "_on_EVENTS_spawn_item")

#### LOGIC ####

func _spawn_item(item_data: ItemData, pos: Vector2) -> void:
	var item = item_scene.instance()
	owner.add_child(item)
	
	item.set_item_data(item_data)
	item.set_global_position(pos)

func _spawn_special_item(item_packed_scene: PackedScene, pos: Vector2) -> void:
	var item = item_packed_scene.instance()
	owner.add_child(item)
	
	item.set_global_position(pos)

#### SIGNAL RESPONSES ####

func _on_EVENTS_spawn_item(item_data: ItemData, pos: Vector2) -> void:
	_spawn_item(item_data, pos)

func _on_EVENTS_spawn_special_item(item_packed_scene: PackedScene, pos: Vector2) -> void:
	_spawn_special_item(item_packed_scene, pos)
