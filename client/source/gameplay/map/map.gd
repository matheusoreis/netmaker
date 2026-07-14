extends Node2D
class_name Map


@onready var ground_01: TileMapLayer = %Ground01
@onready var ground_02: TileMapLayer = %Ground02
@onready var ground_03: TileMapLayer = $Ground03

@onready var below_01: TileMapLayer = %Below01
@onready var below_02: TileMapLayer = %Below02
@onready var below_03: TileMapLayer = $Below03

@onready var above_01: TileMapLayer = %Above01
@onready var above_02: TileMapLayer = %Above02
@onready var above_03: TileMapLayer = $Above03


var _id: int
var _identifier: String
var _start_position: Vector2i
var _start_direction: Vector2i
var _width: int
var _height: int

var _collisions: Dictionary[Vector2i, int] = {}


func setup(id: int, identifier: String, start_position: Vector2i, start_direction: Vector2i, width: int, height: int) -> void:
	_id = id
	_identifier = identifier
	_start_position = start_position
	_start_direction = start_direction
	_width = width
	_height = height


func read_id() -> int:
	return _id


func read_identifier() -> String:
	return _identifier


func read_start_position() -> Vector2i:
	return _start_position


func read_start_direction() -> Vector2i:
	return _start_direction


func read_width() -> int:
	return _width


func read_height() -> int:
	return _height


func read_collisions() -> Dictionary:
	return _collisions


func _get_layers() -> Array[TileMapLayer]:
	return [
		ground_01,
		ground_02,
		below_01,
		below_02,
		above_01,
		above_02,
	]


func is_within_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < _width and pos.y >= 0 and pos.y < _height


func to_screen(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * Constants.TILE_SIZE, cell.y * Constants.TILE_SIZE)


func to_tile(screen_pos: Vector2) -> Vector2i:
	return Vector2i(int(screen_pos.x / Constants.TILE_SIZE), int(screen_pos.y / Constants.TILE_SIZE))


func set_collisions(data: Array) -> void:
	_collisions.clear()

	for entry: Array in data:
		var cell: Vector2i = Vector2i(entry[0], entry[1])
		var flag: int = entry[2]
		_collisions[cell] = flag


func get_collision_flag(cell: Vector2i) -> int:
	return _collisions.get(cell, Constants.CELL_COLLISION_NONE)


func is_solid(cell: Vector2i) -> bool:
	var flag: int = get_collision_flag(cell)
	return (flag & Constants.CELL_COLLISION_FULL_BLOCK) != 0


func can_pass(from: Vector2i, direction: Vector2i) -> bool:
	var to: Vector2i = from + direction

	if not is_within_bounds(from) or not is_within_bounds(to):
		return false

	var from_flag: int = get_collision_flag(from)
	var to_flag: int = get_collision_flag(to)

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


func get_collisions_data() -> Array:
	var data: Array = []
	for cell: Vector2i in _collisions:
		var flag: int = _collisions[cell]
		data.push_back([cell.x, cell.y, flag])
	return data


func clear_all() -> void:
	for layer: TileMapLayer in _get_layers():
		if layer:
			layer.clear()

	_collisions.clear()


func export_map() -> Array:
	var data: Array = []

	for layer: TileMapLayer in _get_layers():
		if not layer:
			continue

		var cells: Array = []
		for cell: Vector2i in layer.get_used_cells():
			var source_id: int = layer.get_cell_source_id(cell)
			var atlas_coord: Vector2i = layer.get_cell_atlas_coords(cell)
			var alt_tile: int = layer.get_cell_alternative_tile(cell)

			cells.push_back([cell.x, cell.y, source_id, atlas_coord.x, atlas_coord.y, alt_tile])

		data.push_back([layer.name, cells])

	return data


func import_map(data: Array) -> void:
	clear_all()

	if data.is_empty():
		return

	var layers_by_name: Dictionary = {}
	for entry: Array in data:
		layers_by_name[entry[0]] = entry[1]

	for layer: TileMapLayer in _get_layers():
		if not layer:
			continue

		var layer_name: String = layer.name
		if not layers_by_name.has(layer_name):
			continue

		var cells: Array = layers_by_name[layer_name]
		for cell_data: Array in cells:
			var cell: Vector2i = Vector2i(cell_data[0], cell_data[1])
			var source_id: int = cell_data[2]
			var atlas_coord: Vector2i = Vector2i(cell_data[3], cell_data[4])
			var alt_tile: int = cell_data[5]

			layer.set_cell(cell, source_id, atlas_coord, alt_tile)
