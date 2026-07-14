extends Node


var actor_id: int = -1

var _maps: Dictionary[int, Map]
var _actors: Dictionary[int, Actor]


func get_map(id: int) -> Map:
	return _maps.get(id)


func add_map(map: Map) -> void:
	if _maps.has(map.id):
		return

	_maps[map.id] = map


func get_actor(id: int) -> Actor:
	return _actors.get(id)


func add_actor(actor: Actor) -> void:
	var id: int = actor.id

	if _actors.has(id):
		return

	_actors[id] = actor
	actor_id = id
