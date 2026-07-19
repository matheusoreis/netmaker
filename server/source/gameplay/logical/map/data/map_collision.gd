extends Resource
class_name MapCollisionData


@export var positions: Array[Vector2i] = []
@export var flags: Array[int] = []


func from_map(map: Map) -> void:
	positions.clear()
	flags.clear()

	var collisions_data = map.collisions_data()
	for entry in collisions_data:
		var pos = Vector2i(entry[0], entry[1])
		var flag = entry[2]

		positions.append(pos)
		flags.append(flag)


func apply_to_map(map: Map) -> void:
	var data: Array = []
	for i in positions.size():
		data.append([positions[i].x, positions[i].y, flags[i]])

	map.set_collisions(data)
