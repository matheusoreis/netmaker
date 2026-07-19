extends Node


var _actors: Dictionary[int, Actor] = {}


func add_actor(peer_id: int, actor: Actor) -> void:
	_actors[peer_id] = actor


func remove_actor(peer_id: int) -> void:
	if not _actors.has(peer_id):
		return

	_actors.erase(peer_id)


func actor(peer_id: int) -> Actor:
	return _actors.get(peer_id, null)


func has_actor(peer_id: int) -> bool:
	return _actors.has(peer_id)


func get_actors_in_map(map_id: int) -> Array[int]:
	var peer_ids: Array[int] = []
	for peer_id: int in _actors:
		var actor = _actors[peer_id]
		if actor.map_id == map_id:
			peer_ids.append(peer_id)
	return peer_ids


func get_map_actors(map_id: int) -> Array[Actor]:
	var actors: Array[Actor] = []
	for peer_id: int in _actors:
		var actor = _actors[peer_id]
		if actor.map_id == map_id:
			actors.append(actor)
	return actors


func clear_all() -> void:
	_actors.clear()


func move_actor(peer_id: int, direction: Vector2i, map: Map) -> bool:
	var actor = _actors.get(peer_id)
	if not actor:
		return false

	var target = actor.map_position + direction

	if not map.is_within_bounds(target):
		return false

	if map.is_solid(target):
		return false

	if not map.can_pass(actor.map_position, direction):
		return false

	map.vacate(actor.map_position)
	map.occupy(target, peer_id)

	actor.map_position = target
	actor.map_direction = direction

	return true
