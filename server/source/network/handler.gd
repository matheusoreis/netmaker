extends Node


func setup() -> Error:
	return Network.register([
		join,
		move,
		update_map
	])


func join(identifier: String, spritesheet: String) -> void:
	var sender_id: int = Network.sender_id()

	var access: Enums.ActorAccess = Enums.ActorAccess.ADMINISTRATOR if identifier == "Raizen" else Enums.ActorAccess.NONE
	var map_id: int = Constants.START_MAP_ID
	var map_position: Vector2i = Constants.START_MAP_POSITION
	var map_direction: Vector2i = Constants.START_MAP_DIRECTION

	var actor: Actor = Actor.new(
		sender_id,
		identifier,
		spritesheet,
		4, 4,
		map_id,
		map_position,
		map_direction,
		access
	)

	# Coloca o ator no mapa usando a abstração
	GameMaps.place_occupant(map_id, map_position, sender_id)

	# Adiciona o ator no gerenciador
	GameActors.place(sender_id, actor)

	# Envia os dados do mapa para o novo jogador
	Sender.map_data(sender_id)

	# Envia os outros para o novo jogador
	Sender.actors(sender_id)

	# Envia para os outros que ele entrou
	Sender.actor(sender_id)


func move(direction: Vector2i) -> void:
	var sender_id: int = Network.sender_id()

	var actor = GameActors.actor(sender_id)
	if not actor:
		return

	var map = GameMaps.map(actor.map_id)
	if not map:
		return

	if not map.can_pass(actor.map_position, direction):
		Sender.move_rejected(sender_id)
		return

	# Calcula nova posição
	var new_position: Vector2i = actor.map_position + direction

	# Remove da posição antiga
	GameMaps.remove_occupant(actor.map_id, actor.map_position, sender_id)

	# Coloca na nova posição
	GameMaps.place_occupant(actor.map_id, new_position, sender_id)

	# Atualiza a posição no ator
	if GameActors.move(sender_id, new_position, direction):
		Sender.move(sender_id, direction)
		return

	# Rollback em caso de falha
	GameMaps.remove_occupant(actor.map_id, new_position, sender_id)
	GameMaps.place_occupant(actor.map_id, actor.map_position, sender_id)

	Sender.move_rejected(sender_id)


func update_map(map_id: int, collision_data: Dictionary) -> void:
	var sender_id: int = Network.sender_id()

	var actor: Actor = GameActors.actor(sender_id)
	if actor == null or actor.access != Enums.ActorAccess.ADMINISTRATOR:
		return

	var map: Map = GameMaps.map(map_id)
	if map == null:
		return

	map.set_collisions(collision_data)

	var collision_resource = MapCollisionData.new()
	collision_resource.from_map(map)

	var path: String = Constants.MAPS_PATH + "collisions/map_%d.tres" % map_id
	var error = ResourceSaver.save(collision_resource, path)

	if error != OK:
		push_error("[MAP] Falha ao salvar colisões do mapa %d: %s" % [map_id, error_string(error)])
		return

	print("[MAP] Colisões do mapa %d salvas com sucesso." % map_id)

	Sender.map_collisions(map_id)
