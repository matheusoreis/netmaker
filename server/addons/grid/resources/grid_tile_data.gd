extends Resource
class_name GridTileData


var blocked: bool = false
var blocked_directions: Array[Vector2i] = []

func blocks_direction(direction: Vector2i) -> bool:
	return blocked_directions.has(direction)
