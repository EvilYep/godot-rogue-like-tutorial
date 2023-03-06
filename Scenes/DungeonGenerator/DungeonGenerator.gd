extends Node2D

class_name DungeonGenerator

const MIN_DUNGEON_DEPTH = 10
enum CELL_TYPE {
	EMPTY,
	WALL
}

onready var tilemap = $TileMap

export var grid_size := Vector2(10, 10)
var grid : Array = []

var walker_array : Array = []
var dijkstra_map : Array = []

var entry_cell : Vector2
var exit_cell : Vector2

#### SUB-CLASS ####

class CellDistance:
	var cell := Vector2.INF
	var dist : int = -1
	
	func _init(_cell: Vector2, _dist: int) -> void:
		cell = _cell
		dist = _dist

#### ACCESSORS ####

func is_class(value: String): return value == "DungeonGenerator" or .is_class(value)
func get_class() -> String: return "DungeonGenerator"

#### BUILT-IN ####

func _ready() -> void:
	_init_grid()
	_update_grid_display()

#### VIRTUALS ####

#### LOGIC ####

func _generate_dungeon() -> void:
	print("Generation started")
	_init_grid()
	dijkstra_map = []
	
	while(_get_dungeon_depth() < MIN_DUNGEON_DEPTH):
		_init_grid()
		dijkstra_map = []
		entry_cell = _get_random_cell()
		_place_walker(entry_cell)
		
		while(!walker_array.empty()):
			for walker in walker_array:
				var accessible_cells = get_accessible_cells(walker.cell)
				walker.step(accessible_cells)
				yield(get_tree().create_timer(0.02), "timeout")
				_update_grid_display()
		
		_compute_cell_distances(entry_cell)
	
	var furtherest_cells = _get_furtherest_cells()
	exit_cell = furtherest_cells[randi() % furtherest_cells.size()]
	
	_place_entry_and_exit_cells()
	_display_dijkstra_map()
	
	print("Generation finished")

func set_cell(cell: Vector2, cell_type: int) -> void:
	grid[cell.x][cell.y] = cell_type

func _init_grid() -> void:
	grid = []
	
	for i in range(grid_size.x):
		grid.append([])
		
		for _j in range(grid_size.y):
			grid[i].append(CELL_TYPE.WALL) 

func _update_grid_display() -> void:
	for i in range(grid_size.x):
		for j in range(grid_size.y):
			var cell_type = grid[i][j]
			
			tilemap.set_cell(i, j, cell_type - 1)

func _place_walker(cell: Vector2, max_nb_steps: int = 9, nb_sub_walkers: int = 2) -> void:
	var walker = Walker.new(cell, max_nb_steps, nb_sub_walkers)
	walker_array.append(walker)
	add_child(walker)
	
	var __ = walker.connect("moved", self, "_on_walker_moved")
	__ = walker.connect("arrived", self, "_on_walker_arrived", [walker])
	__ = walker.connect("sub_walker_creation", self, "_on_walker_sub_walker_creation")

func _get_random_cell() -> Vector2:
	return Vector2(randi() % int(grid_size.x), randi() % int(grid_size.y))

func get_accessible_cells(cell: Vector2) -> Array:
	var adjacent_cells = Utils.get_adjacent_cells(cell)
	var accessibles = []
	
	for adj in adjacent_cells:
		if is_inside_grid(adj) && grid[adj.x][adj.y] == CELL_TYPE.WALL:
			accessibles.append(adj)
	
	return accessibles

func is_inside_grid(cell: Vector2) -> bool:
	return cell.x >= 0 && cell.x < grid_size.x && \
			cell.y >= 0 && cell.y < grid_size.y

func _compute_cell_distances(cell: Vector2, distance : int = 0) -> void:
	if dijkstra_map.empty():
		dijkstra_map.append(CellDistance.new(cell, 0))
	
	distance += 1
	
	var adjacent_cells = Utils.get_adjacent_cells(cell)
	
	for adj_cell in adjacent_cells:
		var tile_id = tilemap.get_cell(adj_cell.x, adj_cell.y)
		
		if tile_id != -1 or !is_inside_grid(adj_cell):
			continue
		
		var cell_dist = get_dijkstra_cell_distance(adj_cell)
		
		if cell_dist == null:
			dijkstra_map.append(CellDistance.new(adj_cell, distance))
			_compute_cell_distances(adj_cell, distance)
		elif cell_dist.dist > distance:
			cell_dist.dist = distance
			_compute_cell_distances(adj_cell, distance)

func get_dijkstra_cell_distance(cell: Vector2) -> CellDistance:
	for cell_dist in dijkstra_map:
		if cell_dist.cell.is_equal_approx(cell) :
			return cell_dist
	return null

func _display_dijkstra_map() -> void:
	for child in $CellDistances.get_children():
		child.queue_free()
	
	var cell_size = tilemap.get_cell_size()
	
	for cell_dist in dijkstra_map:
		var label = Label.new()
		label.text = String(cell_dist.dist)
		label.set_position(cell_dist.cell * cell_size * tilemap.scale)
		$CellDistances.add_child(label)

func _place_entry_and_exit_cells() -> void:
	var entry_id = tilemap.tile_set.find_tile_by_name("entry")
	tilemap.set_cellv(entry_cell, entry_id)

	var exit_id = tilemap.tile_set.find_tile_by_name("exit")
	tilemap.set_cellv(exit_cell, exit_id)

func _get_furtherest_cells() -> PoolVector2Array:
	var dungeon_depth = _get_dungeon_depth()
	var furtherest_cells = PoolVector2Array()
	for cell_dist in dijkstra_map:
		if cell_dist.dist == dungeon_depth:
			furtherest_cells.append(cell_dist.cell)
	return furtherest_cells
	
func _get_dungeon_depth() -> int:
	var max_depth = 0
	for cell_dist in dijkstra_map:
		if cell_dist.dist > max_depth:
			max_depth = cell_dist.dist
	return max_depth

#### INPUTS ####

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		_generate_dungeon()
		
#### SIGNAL RESPONSES ####

func _on_walker_moved(cell: Vector2) -> void:
	set_cell(cell, CELL_TYPE.EMPTY)

func _on_walker_arrived(walker: Walker) -> void:
	walker_array.erase(walker)
	walker.queue_free()

func _on_walker_sub_walker_creation(cell: Vector2, max_nb_steps: int, nb_sub_walkers: int) -> void:
	_place_walker(cell, max_nb_steps, nb_sub_walkers)
