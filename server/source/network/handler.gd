extends Node


func setup() -> Error:
	return Network.register([
		join,
		move,
	])


func join(identifier: String, spritesheet: String) -> void:
	var sender_id: int = Network.sender_id()

	var access: Enums.ActorAccess = Enums.ActorAccess.NONE

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

	# Spawna o novo jogador no servidor
	GameActors.add_actor(sender_id, actor)

	# Envia os dados do mapa para o novo jogador
	Sender.map_data(sender_id)

	# Envia os outros para o novo jogador
	Sender.send_actors(sender_id)

	# Envia para os outros que ele entrou
	Sender.send_actor(sender_id)


func move(direction: Vector2i) -> void:
	var sender_id: int = Network.sender_id()

	var actor = GameActors.actor(sender_id)
	if not actor:
		return

	var map = GameMaps.map(actor.map_id)
	if not map:
		return

	if not GameActors.move_actor(sender_id, direction, map):
		Sender.move_rejected(sender_id)
		return

	Sender.move(sender_id, direction)
