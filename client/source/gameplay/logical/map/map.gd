extends Node2D
class_name Map


@export var id: int

@export var identifier: String

@export var bgm: String
@export var bgs: String

@export var width: int
@export var height: int

@export var actor_collision: bool = true

@export var tilemap_layers: Array[TileMapLayer] = []

var _actor_positions: Dictionary[Vector2i, Array] = {}

var _collisions: Dictionary[Vector2i, int] = {}


func _ready() -> void:
	_load_collisions_from_tiles()


func setup(id: int, identifier: String, bgm: String, bgs: String, width: int, height: int) -> void:
	self.id = id
	self.identifier = identifier
	self.bgm = bgm
	self.bgs = bgs
	self.width = width
	self.height = height

	GameAudio.play_bgm(bgm)
	GameAudio.play_bgs(bgs)


func pixel_size() -> Vector2i:
	return Vector2i(
		width * Constants.TILE_SIZE,
		height * Constants.TILE_SIZE
	)


func collision_flag(cell: Vector2i) -> int:
	return _collisions.get(cell, Constants.CELL_COLLISION_NONE)


func collisions() -> Dictionary[Vector2i, int]:
	return _collisions.duplicate()


func set_collisions(data: Dictionary[Vector2i, int]) -> void:
	_collisions = data.duplicate()


func export_collisions() -> MapCollisionData:
	var resource = MapCollisionData.new()
	resource.from_map(self)
	return resource


func import_collisions(resource: MapCollisionData) -> void:
	resource.apply_to_map(self)


func clear_actors() -> void:
	_actor_positions.clear()


func clear_collisions() -> void:
	_collisions.clear()


func is_within_bounds(position: Vector2i) -> bool:
	return position.x >= 0 and position.x < width and position.y >= 0 and position.y < height


func is_solid(cell: Vector2i) -> bool:
	return (collision_flag(cell) & Constants.CELL_COLLISION_FULL_BLOCK) != 0


func has_actor_at(position: Vector2i) -> bool:
	return _actor_positions.has(position)


func actors_at(position: Vector2i) -> Array[int]:
	var occupants: Array[int] = []
	occupants.assign(_actor_positions.get(position, []))
	return occupants


func to_screen(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * Constants.TILE_SIZE, cell.y * Constants.TILE_SIZE)


func to_tile(screen_position: Vector2) -> Vector2i:
	return Vector2i(
		int(screen_position.x / Constants.TILE_SIZE),
		int(screen_position.y / Constants.TILE_SIZE)
	)


func place_actor(position: Vector2i, peer_id: int) -> void:
	if not _actor_positions.has(position):
		_actor_positions[position] = [] as Array[int]

	var occupants: Array = _actor_positions[position]
	if not occupants.has(peer_id):
		occupants.append(peer_id)


func remove_actor(position: Vector2i, peer_id: int) -> void:
	if not _actor_positions.has(position):
		return

	var occupants: Array = _actor_positions[position]
	occupants.erase(peer_id)

	if occupants.is_empty():
		_actor_positions.erase(position)


func can_pass(from: Vector2i, direction: Vector2i) -> bool:
	var to: Vector2i = from + direction

	if not is_within_bounds(from) or not is_within_bounds(to):
		return false

	if actor_collision and has_actor_at(to):
		return false

	var from_flag: int = collision_flag(from)
	var to_flag: int = collision_flag(to)

	if (from_flag & Constants.CELL_COLLISION_FULL_BLOCK) != 0:
		return false

	if (to_flag & Constants.CELL_COLLISION_FULL_BLOCK) != 0:
		return false

	var direction_flag: int = _direction_to_flag(direction)
	var opposite_flag: int = _direction_to_flag(-direction)

	if (from_flag & direction_flag) != 0:
		return false

	if (to_flag & opposite_flag) != 0:
		return false

	if abs(direction.x) == 1 and abs(direction.y) == 1:
		var horiz_cell: Vector2i = Vector2i(from.x + direction.x, from.y)
		var vert_cell: Vector2i = Vector2i(from.x, from.y + direction.y)

		if is_solid(horiz_cell) or is_solid(vert_cell):
			return false

	return true


func _load_collisions_from_tiles() -> void:
	_collisions.clear()

	for layer: TileMapLayer in tilemap_layers:
		if not layer:
			continue

		for cell: Vector2i in layer.get_used_cells():
			var collision_flag: int = _get_collision_from_tile(layer, cell)
			if collision_flag != Constants.CELL_COLLISION_NONE:
				var current_flag: int = _collisions.get(cell, Constants.CELL_COLLISION_NONE)
				_collisions[cell] = current_flag | collision_flag


func _get_collision_from_tile(layer: TileMapLayer, cell: Vector2i) -> int:
	var tile_data: TileData = layer.get_cell_tile_data(cell)
	if not tile_data:
		return Constants.CELL_COLLISION_NONE
	return tile_data.get_custom_data("collision")


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
