extends Resource
class_name MapCollisionData


@export var positions: Array[Vector2i] = []
@export var flags: Array[int] = []


func from_map(map: Map) -> void:
	positions.clear()
	flags.clear()

	var collisions: Dictionary[Vector2i, int] = map.collisions()
	for cell: Vector2i in collisions:
		positions.append(cell)
		flags.append(collisions[cell])


func apply_to_map(map: Map) -> void:
	if positions.size() != flags.size():
		return

	var data: Dictionary[Vector2i, int] = {}
	for i in positions.size():
		data[positions[i]] = flags[i]

	map.set_collisions(data)
