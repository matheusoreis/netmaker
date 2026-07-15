extends Node


var _actors: Dictionary[int, Actor] = {}

var actor_id: int = -1


func add_actor(actor: Actor) -> void:
	var id: int = actor.id

	if _actors.has(id):
		return

	_actors[id] = actor


func read_actor(id: int) -> Actor:
	return _actors.get(id)


func remove_actor(id: int) -> void:
	if not _actors.has(id):
		return

	var actor: Actor = _actors[id]
	_actors.erase(id)
	actor.queue_free()


func clear_all() -> void:
	for actor: Actor in _actors.values():
		actor.queue_free()

	_actors.clear()
	actor_id = -1


func has_actor(id: int) -> bool:
	return _actors.has(id)


func read_all_actors() -> Array[Actor]:
	return _actors.values()


func read_actor_count() -> int:
	return _actors.size()
