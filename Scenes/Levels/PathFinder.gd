extends Node

class_name PathFinder

onready var tilemap = get_parent()

export var connect_diagonals : bool = false

var astar = AStar2D.new()
var room_size := Vector2.ZERO

#### BUILT-IN ####

func _ready() -> void:
	var __ = EVENTS.connect("obstacle_destroyed", self, "_on_EVENTS_obstacle_destroyed")
	
	room_size = tilemap.get_used_rect().size
	
	_init_astar()
	_disable_all_obstacles_points()

#### LOGIC ####

func find_path(from: Vector2, to: Vector2) -> PoolVector2Array:
	var from_cell = tilemap.world_to_map(from)
	var to_cell = tilemap.world_to_map(to)
	var from_cell_id = _compute_point_index(from_cell)
	var to_cell_id = _compute_point_index(to_cell)
	
	var point_path = astar.get_point_path(from_cell_id, to_cell_id)
	var path := PoolVector2Array()
	
	for i in range(point_path.size()):
		if i == 0 : continue
		var point = point_path[i]
		var world_pos = tilemap.map_to_world(point) + Vector2.ONE * 8
		
		var pos = world_pos if i != point_path.size() - 1 else to
		path.append(pos)
	
	return path

func _init_astar() -> void:
	var cells_array = tilemap.get_used_cells()
	
	# Add every ground cell as a point in astar
	for cell in cells_array:
		var tile_id = tilemap.get_cellv(cell)
		var tile_name = tilemap.tile_set.tile_get_name(tile_id)
		
		if tile_name == "Floor":
			var point_id = _compute_point_index(cell)
			astar.add_point(point_id, cell)
	
	_astar_connect_points(cells_array, connect_diagonals)

func _compute_point_index(cell: Vector2) -> int:
	return int(abs(cell.x + room_size.x * cell.y))

func _astar_connect_points(point_array: Array, connect_diags : bool = true) -> void:
	for point in point_array:
		var point_index = _compute_point_index(point)
		
		if !astar.has_point(point_index):
			continue
		
		for y_offset in range(3):
			for x_offset in range(3):
				if !connect_diags && x_offset in [0, 2] && y_offset in [0, 2]:
					continue
				var point_relative = Vector2(point.x + x_offset -1, point.y + y_offset -1)
				var point_rel_id = _compute_point_index(point_relative)
				if point_relative == point or !astar.has_point(point_rel_id):
					continue
				astar.connect_points(point_index, point_rel_id)

func _disable_all_obstacles_points() -> void:
	for obstacle in get_tree().get_nodes_in_group("Obstacle"):
		_update_obstacle_point(obstacle, true)

func _update_obstacle_point(obstacle: Node2D, disabled: bool)-> void:
	var obstacle_pos = obstacle.get_global_position()
	var cell = tilemap.world_to_map(obstacle_pos)
	var point_id = _compute_point_index(cell)
	
	astar.set_point_disabled(point_id, disabled)

func is_position_valid(pos: Vector2) -> bool:
	var cell = tilemap.world_to_map(pos)
	var point_id = _compute_point_index(cell)
	
	return astar.has_point(point_id) && !astar.is_point_disabled(point_id)

#### SIGNAL RESPONSES ####

func _on_EVENTS_obstacle_destroyed(obstacle: Node2D) -> void:
	_update_obstacle_point(obstacle, false)
