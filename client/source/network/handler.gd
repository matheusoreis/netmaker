extends Node


func setup() -> Error:
	return Network.register([
		enter_map,
		player_joined,
		player_left,
		player_moved,
		move_rejected
	])


func enter_map(actor_id: int, data: Array, actors: Array) -> void:
	GameActors.actor_id = actor_id

	var map_id: int = data[0]
	var map_name: String = data[1]
	var start_position: Vector2i = data[2]
	var start_direction: Vector2i = data[3]

	var scene: Scene = GameScenes.read_current_scene()
	var map: Map = GameMaps.load_map(map_name)
	if map:
		scene.add_child(map)

	for entry: Array in actors:
		var index: int = entry[0]
		var id: int = entry[1]
		var identifier: String = entry[2]
		var sprite: String = entry[3]
		var access: int = entry[4]
		var entry_map_name: String = str(entry[5])  # Pode ser int ou string
		var position: Vector2i = entry[6]
		var direction: Vector2i = entry[7]

		var actor: Actor = Actor.new(id, identifier, sprite, 4, 4, position, direction)
		actor.name = "Actor%d" % id

		if id == actor_id:
			actor.write_is_local(true)
			actor.setup_camera(map)

		GameActors.add_actor(actor)
		map.add_child(actor)


func player_joined(peer_id: int, id: int, identifier: String, sprite: String, access: int, map_id: int, position: Vector2i, direction: Vector2i) -> void:
	# Verificar se o actor já existe (evitar duplicatas)
	if GameActors.has_actor(id):
		return

	var actor: Actor = Actor.new(id, identifier, sprite, 4, 4, position, direction)
	actor.name = "Actor%d" % id

	GameActors.add_actor(actor)

	var map: Map = GameMaps.read_map()
	if map:
		map.add_child(actor)


func player_left(peer_id: int) -> void:
	GameActors.remove_actor(peer_id)


func player_moved(peer_id: int, direction: Vector2i) -> void:
	var actor: Actor = GameActors.read_actor(peer_id)
	if not actor:
		return

	var map: Map = GameMaps.read_map()
	if not map:
		return

	actor.move_to(map, direction)


func move_rejected(position: Vector2i) -> void:
	var actor: Actor = GameActors.read_actor(GameActors.actor_id)
	if not actor:
		return

	actor.write_map_position(position)
	actor.write_visual_offset(Vector2.ZERO)
	actor._play_idle()
