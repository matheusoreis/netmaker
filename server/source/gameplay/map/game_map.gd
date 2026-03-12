extends GridMap2D
class_name GameMap

signal player_entered(peer_id: int)
signal player_left(peer_id: int)
signal player_moved(peer_ids: Array, entity_id: int, direction: Vector2i)
signal npc_moved(peer_ids: Array, entity_id: int, direction: Vector2i)

var _delta: float = 0.0
var _tick_counters: Dictionary[int, float] = {}
var _players: Dictionary[int, GridEntity2D] = {}
var _npcs: Array[Npc] = []


func add_player(peer_id: int, entity: GridEntity2D, spawn_pos: Vector2i) -> void:
	if _players.has(peer_id):
		push_warning("GameMap [%s]: peer %d já está no mapa." % [map_data.identifier, peer_id])
		return

	_players[peer_id] = entity
	add_entity(entity, spawn_pos)
	_set_active(true)
	player_entered.emit(peer_id)


func remove_player(peer_id: int) -> void:
	var entity: GridEntity2D = _players.get(peer_id)
	if entity == null:
		return

	remove_entity(entity)
	_players.erase(peer_id)
	player_left.emit(peer_id)

	if _players.is_empty() and _npcs.is_empty():
		_set_active(false)


## Tenta mover o jogador. Retorna o MoveResult para que o caller
## possa enviar correção ao cliente em caso de rejeição.
func move_player(peer_id: int, direction: Vector2i) -> MoveResult:
	var entity: GridEntity2D = _players.get(peer_id)
	if entity == null:
		return null

	var result: MoveResult = request_move(entity, direction)

	if result.success:
		player_moved.emit(_players.keys(), entity.entity_id, direction)

	return result


func spawn_npc(npc_id: int, spawn_pos: Vector2i) -> Npc:
	var npc: Npc = Npc.new()
	add_child(npc)
	npc.move_started.connect(func(from: Vector2i, to: Vector2i) -> void:
		npc_moved.emit(_players.keys(), npc.entity_id, to - from)
	)
	npc.setup(self, spawn_pos, npc_id)
	_npcs.append(npc)
	_set_active(true)
	return npc


func get_player_ids() -> Array:
	return _players.keys()


func has_player(peer_id: int) -> bool:
	return _players.has(peer_id)


func get_player_entity(peer_id: int) -> GridEntity2D:
	return _players.get(peer_id)


func get_npcs() -> Array[Npc]:
	return _npcs


func _set_active(value: bool) -> void:
	set_process(value)
	set_physics_process(value)


func _process(delta: float) -> void:
	_delta = delta
	_tick()


func _tick() -> void:
	_run_on_tick(0.25, _tick_npcs)


func _run_on_tick(interval_sec: float, callback: Callable) -> void:
	var key: int = callback.get_method().hash()
	_tick_counters[key] = _tick_counters.get(key, 0.0) + _delta

	if _tick_counters[key] < interval_sec:
		return

	_tick_counters[key] -= interval_sec
	callback.call()


func _tick_npcs() -> void:
	for npc: Npc in _npcs:
		npc.tick()
