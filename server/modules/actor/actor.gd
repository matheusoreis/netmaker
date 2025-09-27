class_name ActorModule extends Node


signal added(peer: ENetPacketPeer, actor: Dictionary)
signal removed(peer: ENetPacketPeer, actor: Dictionary)
signal updated(peer: ENetPacketPeer, actor: Dictionary)


var _actors: Dictionary = {}


func add(peer: ENetPacketPeer, data: Dictionary) -> void:
	_actors[peer] = data
	added.emit(peer, data)


func read(peer: ENetPacketPeer) -> Dictionary:
	return _actors.get(peer, null)


func read_all() -> Array:
	return _actors.values()


func remove(peer: ENetPacketPeer) -> void:
	if not _actors.has(peer):
		return

	var actor: Dictionary = _actors[peer]
	_actors.erase(peer)

	removed.emit(peer, actor)


func patch(peer: ENetPacketPeer, data: Dictionary) -> void:
	if not _actors.has(peer):
		return

	var actor: Dictionary = _actors[peer]
	actor.merge(data, true)

	_actors[peer] = actor
	updated.emit(peer, actor)


func is_in_map(peer: ENetPacketPeer, map_id: int) -> bool:
	var a := read(peer)
	return a != null and a.get("map_id", null) == map_id
