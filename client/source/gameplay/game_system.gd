extends Node


var actor_id: int = -1


var _map: Map = null
var _actors: Dictionary[int, Actor]


func get_map() -> Map:
	return _map


func add_map(map: Map) -> void:
	_map = map


func get_actor(id: int) -> Actor:
	return _actors.get(id)


func add_actor(actor: Actor) -> void:
	var id: int = actor.id

	if _actors.has(id):
		return

	_actors[id] = actor
	actor_id = id
