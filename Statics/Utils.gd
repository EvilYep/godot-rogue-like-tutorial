extends Object

class_name Utils

const DIRECTIONS_4 = {
	"up" : Vector2.UP,
	"right" : Vector2.RIGHT,
	"down" : Vector2.DOWN,
	"left" : Vector2.LEFT
}

static func get_adjacent_cells(cell: Vector2) -> Array:
	var adjacent_cells = []
	for dir in DIRECTIONS_4.values():
		adjacent_cells.append(cell + dir)
	
	return adjacent_cells
