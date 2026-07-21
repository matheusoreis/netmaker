extends Node


var _actors: Dictionary[int, Actor] = {}

var _local_actor_id: int = -1


func add_actor(actor_id: int, actor: Actor) -> void:
	_actors[actor_id] = actor


func remove_actor(actor_id: int) -> void:
	var target: Actor = _actors.get(actor_id)
	if not target:
		return

	_actors.erase(actor_id)
	target.queue_free()


func actor(actor_id: int) -> Actor:
	return _actors.get(actor_id, null)


func has_actor(actor_id: int) -> bool:
	return _actors.has(actor_id)


func set_local_actor(actor_id: int) -> void:
	_local_actor_id = actor_id


func local_actor() -> Actor:
	return _actors.get(_local_actor_id, null)


func get_actors_in_map(map_id: int) -> Array[int]:
	var ids: Array[int] = []
	for actor_id: int in _actors:
		var target: Actor = _actors[actor_id]
		if target.map_id == map_id:
			ids.append(actor_id)
	return ids


func clear_all() -> void:
	for actor_id: int in _actors:
		var target: Actor = _actors[actor_id]
		target.queue_free()

	_actors.clear()
	_local_actor_id = -1
