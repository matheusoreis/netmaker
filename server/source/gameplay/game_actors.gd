extends Node


var _actors: Dictionary[int, Actor] = {}


func add_actor(actor: Actor) -> void:
	_actors[actor.id] = actor


func remove_actor(actor_id: int) -> void:
	if _actors.has(actor_id):
		_actors.erase(actor_id)


func actor(actor_id: int) -> Actor:
	return _actors.get(actor_id, null)


func has_actor(actor_id: int) -> bool:
	return _actors.has(actor_id)


func get_actors_in_map(map_id: int) -> Array[int]:
	var actor_ids: Array[int] = []
	for actor_id: int in _actors:
		var actor = _actors[actor_id]
		if actor.map_id == map_id:
			actor_ids.append(actor_id)
	return actor_ids


func get_map_actors(map_id: int) -> Array[Actor]:
	var actors: Array[Actor] = []
	for actor_id: int in _actors:
		var actor = _actors[actor_id]
		if actor.map_id == map_id:
			actors.append(actor)
	return actors


func clear_all() -> void:
	_actors.clear()
