extends Node2D
class_name Map


var id: int
var identifier: String

var start_position: Vector2i
var start_direction: Vector2i

var width: int
var height: int


func _init(id: int, identifier: String, start_position: Vector2i, start_direction: Vector2i, width: int, height: int) -> void:
	self.id = id
	self.identifier = identifier

	self.start_position = start_position
	self.start_direction = start_direction

	self.width = width
	self.height = height


func is_within_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < width and pos.y >= 0 and pos.y < height


func to_screen(cell: Vector2i) -> Vector2:
	return Vector2(
		cell.x * Constants.TILE_SIZE,
		cell.y * Constants.TILE_SIZE,
	)


func to_tile(screen_pos: Vector2) -> Vector2i:
	return Vector2i(
		int(screen_pos.x / Constants.TILE_SIZE),
		int(screen_pos.y / Constants.TILE_SIZE),
	)
