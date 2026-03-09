extends GridMap2D
class_name GameMap


signal player_entered(peer_id: int)
signal player_left(peer_id: int)
signal player_moved(peer_ids: Array, entity_id: int, direction: Vector2i)


var _delta: float = 0.0
var _tick_counters: Dictionary[int, float] = {}

var _players: Dictionary[int, GridEntity2D] = {}


func add_player(peer_id: int, entity: GridEntity2D, spawn_pos: Vector2i) -> void:
	_players[peer_id] = entity
	add_entity(entity, spawn_pos)
	_set_active(true)
	player_entered.emit(peer_id)


func remove_player(peer_id: int) -> void:
	var entity: GridEntity2D = _players.get(peer_id)
	if entity:
		remove_entity(entity)
		_players.erase(peer_id)
		player_left.emit(peer_id)

	if _players.is_empty():
		_set_active(false)


func move_player(peer_id: int, direction: Vector2i) -> void:
	var entity: GridEntity2D = _players.get(peer_id)
	if entity == null:
		return

	var result: MoveResult = request_move(entity, direction)
	if not result.success:
		return

	player_moved.emit(_players.keys(), entity.entity_id, direction)


func get_player_ids() -> Array:
	return _players.keys()


func has_player(peer_id: int) -> bool:
	return _players.has(peer_id)


func get_player_entity(peer_id: int) -> GridEntity2D:
	return _players.get(peer_id)


func _set_active(value: bool) -> void:
	set_process(value)
	set_physics_process(value)


func _process(delta: float) -> void:
	_delta = delta
	_tick()


func _tick() -> void:
	_run_on_tick(0.5, _tick_npcs)


func _run_on_tick(interval_sec: float, callback: Callable) -> void:
	var key: int = callback.get_method().hash()
	_tick_counters[key] = _tick_counters.get(key, 0.0) + _delta

	if _tick_counters[key] < interval_sec:
		return

	_tick_counters[key] -= interval_sec
	callback.call()


func _tick_npcs() -> void:
	pass
