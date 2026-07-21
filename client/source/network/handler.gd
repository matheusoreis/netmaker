extends Node


func setup() -> Error:
	return Network.register([
		map_data,
		map_collisions,
		receive_actors,
		receive_actor,
		actor_moved,
		move_rejected,
		actor_left,
	])


func map_data(id: int, identifier: String, bgm: String, bgs: String, width: int, height: int, actor_collision: bool) -> void:
	GameMaps.load_map(id, identifier, bgm, bgs, width, height, actor_collision)

	var scene: Scene = GameScenes.read_current_scene()
	if scene == null:
		return

	var map: Map = GameMaps.current_map()
	if map == null:
		return

	scene.add_child(map)


func map_collisions(collision_data: Dictionary) -> void:
	var map: Map = GameMaps.current_map()
	if map == null:
		return

	map.set_collisions(collision_data)


func receive_actors(actors_data: Array) -> void:
	var map: Map = GameMaps.current_map()
	if not map:
		return

	for actor_data in actors_data:
		var actor = Actor.new(
			actor_data[0],  # id
			actor_data[1],  # identifier
			actor_data[2],  # spritesheet
			actor_data[3],  # spritesheet_cols
			actor_data[4],  # spritesheet_rows
			actor_data[5],  # map_id
			actor_data[6],  # map_position
			actor_data[7],  # map_direction
			actor_data[8]   # access
		)

		actor.name = "Actor_%d" % actor.id

		# Usa a flag enviada pelo servidor
		if actor_data[9]:  # is_local
			actor.is_local = true
			actor.setup_camera(map)
			GameActors.set_local_actor(actor.id)

		GameActors.add_actor(actor.id, actor)
		map.add_child(actor)


func receive_actor(actor_data: Array) -> void:
	var map: Map = GameMaps.current_map()
	if not map:
		return

	if GameActors.has_actor(actor_data[0]):
		return

	var actor = Actor.new(
		actor_data[0],  # id
		actor_data[1],  # identifier
		actor_data[2],  # spritesheet
		actor_data[3],  # spritesheet_cols
		actor_data[4],  # spritesheet_rows
		actor_data[5],  # map_id
		actor_data[6],  # map_position
		actor_data[7],  # map_direction
		actor_data[8]   # access
	)

	actor.name = "Actor_%d" % actor.id

	actor.is_local = false

	GameActors.add_actor(actor.id, actor)
	map.add_child(actor)


func actor_moved(peer_id: int, direction: Vector2i) -> void:
	var actor: Actor = GameActors.actor(peer_id)
	if not actor:
		return

	actor.move_to(direction)


func move_rejected(position: Vector2i) -> void:
	var actor: Actor = GameActors.local_actor()
	if not actor:
		return

	actor.map_position = position


func actor_left(peer_id: int) -> void:
	var actor: Actor = GameActors.actor(peer_id)
	if not actor:
		return

	actor.queue_free()
	GameActors.remove_actor(peer_id)
