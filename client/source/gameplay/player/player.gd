extends GridEntity2D
class_name Player

@export var move_speed: float = 128.0
@export var sprite_2d: Sprite2D
@export var camera_2d: Camera2D

var _move_target: Vector2 = Vector2.ZERO
var _is_moving: bool = false
var _is_local: bool = false


func setup_as_local() -> void:
	_is_local = true
	if camera_2d:
		camera_2d.enabled = true


func setup_as_remote() -> void:
	_is_local = false
	if camera_2d:
		camera_2d.enabled = false


func on_added_to_map() -> void:
	super.on_added_to_map()
	_move_target = position

	var blocked_count: int = 0
	for x in range(current_map.map_data.bounds.size.x):
		for y in range(current_map.map_data.bounds.size.y):
			if current_map.is_cell_blocked(Vector2i(x, y)):
				blocked_count += 1
				if blocked_count <= 5:
					print("[PLAYER] Tile bloqueado: (%d, %d)" % [x, y])
	print("[PLAYER] Total tiles bloqueados: %d" % blocked_count)


func _process(delta: float) -> void:
	if _is_moving:
		_process_interpolation(delta)


func _advance_path() -> void:
	if _is_moving:
		return
	super._advance_path()


func move(direction: Vector2i) -> void:
	_attempt_move(direction)


func move_remote(new_pos: Vector2i, direction: Vector2i) -> void:
	if not current_map:
		return

	if direction != facing:
		facing = direction
		direction_changed.emit(facing)

	var visual_from: Vector2 = position

	go_to(new_pos)

	position = visual_from
	_move_target = current_map.grid_to_world(new_pos)
	_is_moving = true

	move_started.emit(new_pos - direction, new_pos)


func _attempt_move(direction: Vector2i) -> void:
	if not current_map or not can_move or _is_moving:
		return

	var destino: Vector2i = map_position + direction
	print("[PLAYER] pos: %s | destino: %s | bloqueado: %s | dentro do mapa: %s" % [
		map_position,
		destino,
		current_map.is_cell_blocked(destino),
		current_map.is_within_map(destino)
	])

	if direction != facing:
		facing = direction
		direction_changed.emit(facing)

	var result: GridMap2D.MoveResult = current_map.request_move(self, direction)

	print("[PLAYER] resultado: success=%s | reason='%s'" % [result.success, result.rejection_reason])

	if not result.success:
		move_blocked.emit(result.to, result.rejection_reason)
		_queued_path.clear()
		return

	var from: Vector2i = result.from
	_move_target = result.world_target
	_is_moving = true

	current_map.confirm_move(self, from, map_position)
	move_started.emit(from, map_position)


func _process_interpolation(delta: float) -> void:
	if position.distance_to(_move_target) < 1.0:
		position = _move_target
		_is_moving = false
		move_finished.emit(map_position)
		_advance_path()
		return

	position = position.move_toward(_move_target, move_speed * delta)
