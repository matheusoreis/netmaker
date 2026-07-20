extends Node


var _actors: Dictionary[int, Actor] = {}


func place(peer_id: int, actor: Actor) -> void:
	_actors[peer_id] = actor


func remove(peer_id: int) -> void:
	if not _actors.has(peer_id):
		return

	_actors.erase(peer_id)


func actor(peer_id: int) -> Actor:
	return _actors.get(peer_id, null)


func has(peer_id: int) -> bool:
	return _actors.has(peer_id)


func in_map(map_id: int) -> Array[Actor]:
	var actors_found: Array[Actor] = []
	for peer_id: int in _actors:
		var actor: Actor = _actors[peer_id]
		if actor.map_id == map_id:
			actors_found.append(actor)
	return actors_found


func peer_ids_in_map(map_id: int) -> Array[int]:
	var peer_ids_found: Array[int] = []
	for peer_id: int in _actors:
		var actor: Actor = _actors[peer_id]
		if actor.map_id == map_id:
			peer_ids_found.append(peer_id)
	return peer_ids_found


func move(peer_id: int, map_position: Vector2i, map_direction: Vector2i) -> bool:
	var target: Actor = _actors.get(peer_id)
	if not target:
		return false

	target.map_position = map_position
	target.map_direction = map_direction
	return true
