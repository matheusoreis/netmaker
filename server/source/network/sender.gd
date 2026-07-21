extends Node


func map_data(peer_id: int) -> void:
	var actor: Actor = GameActors.actor(peer_id)
	if actor == null:
		return

	var map: Map = GameMaps.map(actor.map_id)
	if map == null:
		return

	Network.exec(peer_id, "map_data", [
		map.id, map.identifier, map.bgm, map.bgs, map.width, map.height, map.actor_collision
	])


func map_collisions(peer_id: int) -> void:
	var actor: Actor = GameActors.actor(peer_id)
	if actor == null:
		return

	var map: Map = GameMaps.map(actor.map_id)
	if not map:
		return

	var collision_data: Dictionary[Vector2i, int] = map.collisions()
	Network.exec(peer_id, "map_collisions", [collision_data])


func actors(peer_id: int) -> void:
	var actor: Actor = GameActors.actor(peer_id)
	if actor == null:
		return

	var actors: Array[Actor] = GameActors.in_map(actor.map_id)

	var actors_data: Array = []
	for actor_data in actors:
		actors_data.push_back([
			actor_data.id,
			actor_data.identifier,
			actor_data.spritesheet,
			actor_data.spritesheet_cols,
			actor_data.spritesheet_rows,
			actor_data.map_id,
			actor_data.map_position,
			actor_data.map_direction,
			actor_data.access,
			actor_data.id == peer_id
		])

	Network.exec(peer_id, "receive_actors", [actors_data])


func actor(peer_id: int) -> void:
	var actor: Actor = GameActors.actor(peer_id)
	if actor == null:
		return

	var other_peers: Array[int] = GameActors.peer_ids_in_map(actor.map_id)
	other_peers.erase(peer_id)

	var actor_data = [
		actor.id,
		actor.identifier,
		actor.spritesheet,
		actor.spritesheet_cols,
		actor.spritesheet_rows,
		actor.map_id,
		actor.map_position,
		actor.map_direction,
		actor.access
	]

	for target_peer in other_peers:
		Network.exec(target_peer, "receive_actor", [actor_data])


func move(peer_id: int, direction: Vector2i) -> void:
	var actor: Actor = GameActors.actor(peer_id)
	if actor == null:
		return

	var targets: Array[int] = GameActors.peer_ids_in_map(actor.map_id)
	targets.erase(peer_id)

	Network.exec(targets, "actor_moved", [peer_id, direction])


func move_rejected(peer_id: int) -> void:
	var actor: Actor = GameActors.actor(peer_id)
	if actor == null:
		return

	Network.exec(peer_id, "move_rejected", [actor.map_position])


func left(peer_id: int) -> void:
	var actor: Actor = GameActors.actor(peer_id)
	if actor == null:
		return

	var targets: Array[int] = GameActors.peer_ids_in_map(actor.map_id)
	targets.erase(peer_id)

	for target in targets:
		Network.exec(target, "actor_left", [peer_id])
