extends Character
class_name Actor


var access: Enums.ActorAccess
var is_local: bool = false

var _camera: ActorCamera


func _init(id: int, identifier: String, spritesheet: String, spritesheet_cols: int, spritesheet_rows: int, map_id: int, map_position: Vector2i, map_direction: Vector2i, access: Enums.ActorAccess) -> void:
	super(id, identifier, spritesheet, spritesheet_cols, spritesheet_rows, map_id, map_position, map_direction)

	self.access = access


func _ready() -> void:
	super()

	if is_local:
		_ensure_camera()


func setup_camera(map: Map) -> void:
	if not is_local:
		return

	_ensure_camera()
	_camera.set_map_limits(map)


func move_to(direction: Vector2i) -> void:
	if not is_local:
		super(direction)
		return

	if _is_walking:
		return

	var map: Map = GameMaps.current_map()
	if not map:
		return

	var target: Vector2i = map_position + direction
	if not _can_move_to(map, target):
		return

	_execute_move(direction)
	Sender.move(direction)


func _can_move_to(map: Map, target: Vector2i) -> bool:
	var direction: Vector2i = target - map_position
	return map.can_pass(map_position, direction)


func _sync_map_occupancy(old_position: Vector2i, new_position: Vector2i) -> void:
	var map: Map = GameMaps.current_map()
	if not map:
		return

	map.remove_actor(old_position, id)
	map.place_actor(new_position, id)


func _ensure_camera() -> void:
	if _camera:
		return

	_camera = ActorCamera.new()
	_camera.name = "Camera"
	add_child(_camera)


func _remove_camera() -> void:
	if not _camera:
		return

	_camera.queue_free()
	_camera = null
