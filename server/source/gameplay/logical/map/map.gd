extends Node
class_name Map


var id: int

var identifier: String

var bgm: String
var bgs: String

var width: int
var height: int

var _blockers: Dictionary[Vector2i, int] = {}
var _collisions: Dictionary[Vector2i, int] = {}


func _init(id: int, identifier: String, bgm: String, bgs: String, width: int, height: int) -> void:
	self.id = id
	self.identifier = identifier
	self.bgm = bgm
	self.bgs = bgs
	self.width = width
	self.height = height


func pixel_size() -> Vector2i:
	return Vector2i(
		width * Constants.TILE_SIZE,
		height * Constants.TILE_SIZE
	)


func collision_flag(cell: Vector2i) -> int:
	return _collisions.get(cell, Constants.CELL_COLLISION_NONE)


func collisions_data() -> Array:
	var data: Array = []
	for cell: Vector2i in _collisions:
		data.push_back([cell.x, cell.y, _collisions[cell]])
	return data


func set_collisions(data: Array) -> void:
	_collisions.clear()
	for entry: Array in data:
		_collisions[Vector2i(entry[0], entry[1])] = entry[2]


func export_collisions() -> MapCollisionData:
	var resource = MapCollisionData.new()
	resource.from_map(self)
	return resource


func import_collisions(resource: MapCollisionData) -> void:
	resource.apply_to_map(self)


func is_within_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < width and pos.y >= 0 and pos.y < height


func is_solid(cell: Vector2i) -> bool:
	return (collision_flag(cell) & Constants.CELL_COLLISION_FULL_BLOCK) != 0


func is_blocked(pos: Vector2i) -> bool:
	return _blockers.has(pos)


func to_screen(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * Constants.TILE_SIZE, cell.y * Constants.TILE_SIZE)


func to_tile(screen_pos: Vector2) -> Vector2i:
	return Vector2i(
		int(screen_pos.x / Constants.TILE_SIZE),
		int(screen_pos.y / Constants.TILE_SIZE)
	)


func occupy(pos: Vector2i, entity_id: int) -> void:
	_blockers[pos] = entity_id


func vacate(pos: Vector2i) -> void:
	_blockers.erase(pos)


func can_pass(from: Vector2i, direction: Vector2i) -> bool:
	var to: Vector2i = from + direction

	if not is_within_bounds(from) or not is_within_bounds(to):
		return false

	if is_blocked(to):
		return false

	var from_flag: int = collision_flag(from)
	var to_flag: int = collision_flag(to)

	if (from_flag & Constants.CELL_COLLISION_FULL_BLOCK) != 0:
		return false

	if (to_flag & Constants.CELL_COLLISION_FULL_BLOCK) != 0:
		return false

	var direction_flag: int = _direction_to_flag(direction)

	if (from_flag & direction_flag) != 0:
		return false

	if abs(direction.x) == 1 and abs(direction.y) == 1:
		var horiz_cell: Vector2i = Vector2i(from.x + direction.x, from.y)
		var vert_cell: Vector2i = Vector2i(from.x, from.y + direction.y)

		if is_solid(horiz_cell) or is_solid(vert_cell):
			return false

	return true


func _direction_to_flag(direction: Vector2i) -> int:
	match direction:
		Vector2i(0, -1):
			return Constants.CELL_COLLISION_NORTH
		Vector2i(1, 0):
			return Constants.CELL_COLLISION_EAST
		Vector2i(0, 1):
			return Constants.CELL_COLLISION_SOUTH
		Vector2i(-1, 0):
			return Constants.CELL_COLLISION_WEST
		_:
			return Constants.CELL_COLLISION_NONE
