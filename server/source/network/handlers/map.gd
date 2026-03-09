extends Node
class_name MapHandler

const DEFAULT_MAP: String = "floresta"
const DEFAULT_SPAWN: Vector2i = Vector2i(5, 5)

var _network: Network
var _map_cache: MapCache


func initialize(network: Network, map_cache: MapCache) -> void:
	_network = network
	_map_cache = map_cache

	for map: GameMap in _map_cache.maps.values():
		map.player_moved.connect(
			func(peer_ids: Array, entity_id: int, direction: Vector2i) -> void:
				_on_player_moved(peer_ids, entity_id, direction)
		)

		map.player_entered.connect(
			func(peer_id: int) -> void:
				_on_player_entered(map, peer_id)
		)

		map.player_left.connect(
			func(peer_id: int) -> void:
				_on_player_left(map, peer_id)
		)

	_network.register("game.map", [
		move,
		entered,
		left,
	])


func move(ctx: EnhancedRpc.RpcContext, buf: StreamPeerBuffer) -> void:
	var direction: Vector2i = Vector2i(
		buf.get_8(), buf.get_8()
	)

	var map: GameMap = _get_player_map(ctx.sender_id)
	if map == null:
		return

	map.move_player(ctx.sender_id, direction)


func entered(ctx: EnhancedRpc.RpcContext, _buf: StreamPeerBuffer) -> void:
	var map: GameMap = _map_cache.get_map(DEFAULT_MAP)
	if map == null:
		push_warning("[MAP HANDLER] Mapa padrão '%s' não encontrado." % DEFAULT_MAP)
		return

	var entity: GridEntity2D = GridEntity2D.new()
	entity.entity_id = ctx.sender_id

	map.add_player(ctx.sender_id, entity, DEFAULT_SPAWN)


func left(ctx: EnhancedRpc.RpcContext, _buf: StreamPeerBuffer) -> void:
	var map: GameMap = _get_player_map(ctx.sender_id)
	if map == null:
		return

	map.remove_player(ctx.sender_id)


func _on_player_moved(peer_ids: Array, entity_id: int, direction: Vector2i) -> void:
	var targets: Array = peer_ids.filter(
		func(id: int) -> bool:
			return id != entity_id
	)

	if targets.is_empty():
		return

	_network.exec(targets, "game.map.player_moved", func(buf: StreamPeerBuffer) -> void:
		buf.put_u32(entity_id)
		buf.put_8(direction.x)
		buf.put_8(direction.y)
	)


func _on_player_entered(map: GameMap, peer_id: int) -> void:
	var entity: GridEntity2D = map.get_player_entity(peer_id)

	var others: Array = map.get_player_ids().filter(
		func(id: int) -> bool:
			return id != peer_id
	)

	if not others.is_empty():
		_network.exec(others, "game.map.player_spawned", func(buf: StreamPeerBuffer) -> void:
			buf.put_u32(entity.entity_id)
			buf.put_16(entity.map_position.x)
			buf.put_16(entity.map_position.y)
		)

	for other_id: int in others:
		var other: GridEntity2D = map.get_player_entity(other_id)
		_network.exec(peer_id, "game.map.player_spawned", func(buf: StreamPeerBuffer) -> void:
			buf.put_u32(other.entity_id)
			buf.put_16(other.map_position.x)
			buf.put_16(other.map_position.y)
		)


func _on_player_left(map: GameMap, peer_id: int) -> void:
	var others: Array = map.get_player_ids()
	if others.is_empty():
		return

	_network.exec(others, "game.map.player_despawned", func(buf: StreamPeerBuffer) -> void:
		buf.put_u32(peer_id)
	)


func _get_player_map(peer_id: int) -> GameMap:
	for map: GameMap in _map_cache.maps.values():
		if map.has_player(peer_id):
			return map
	return null
