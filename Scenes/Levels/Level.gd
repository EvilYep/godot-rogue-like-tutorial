extends YSort

onready var pathfinder = $Tilemap/PathFinder

func _ready() -> void:
	var enemies = get_tree().get_nodes_in_group("Enemy")
	
	for enemy in enemies:
		enemy.pathfinder = pathfinder
