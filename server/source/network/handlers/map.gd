extends RefCounted
class_name MapHandler


## Serviço de rede utilizado pelo handler.
var _network: Network

## Serviço responsável pela autenticação das contas.
var _auth_service: AuthService
## Serviço responsável pelo gerenciamento dos personagens.
var _character_service: CharacterService
## Serviço responsável pelo gerenciamento dos mapas.
var _map_service: MapService


## Cria um handler de mapas.
func _init(network: Network, auth_service: AuthService, character_service: CharacterService, map_service: MapService) -> void:
	_network = network
	_auth_service = auth_service
	_character_service = character_service
	_map_service = map_service


## Registra os eventos de mapas na rede.
func register() -> Error:
	return _network.register([
		map_data,
		enter_map,
		move_character,
		update_map,
	])


## Remove os eventos de mapas da rede.
func unregister() -> Error:
	return _network.unregister([
		map_data,
		enter_map,
		move_character,
		update_map,
	])


## Envia os dados do mapa atual ao jogador.
func map_data() -> void:
	var sender_id: int = _network.sender_id()

	var character: Character = _character_service.get_character(sender_id)
	if character == null:
		_network.exec(sender_id, &"alert", ["NO_CHARACTER_SELECTED"])
		return

	var map: Map = _map_service.get_map(character.map)
	if map == null:
		_network.exec(sender_id, &"alert", ["MAP_NOT_FOUND"])
		return

	_send_map_data(sender_id, map)


## Insere o jogador no mapa atual.
func enter_map() -> void:
	var sender_id: int = _network.sender_id()

	if not _character_service.has_character(sender_id):
		_network.exec(sender_id, &"alert", ["NO_CHARACTER_SELECTED"])
		return

	_enter_map(sender_id)


## Remove o jogador do mapa atual.
func leave_map(peer_id: int) -> void:
	_leave_map(peer_id)


## Move o personagem do jogador na direção informada.
func move_character(direction: Vector2i) -> void:
	var sender_id: int = _network.sender_id()

	var character: Character = _character_service.get_character(sender_id)
	if character == null:
		_network.exec(sender_id, &"alert", ["NO_CHARACTER_SELECTED"])
		return

	var map: Map = _map_service.get_map(character.map)
	if map == null:
		_network.exec(sender_id, &"alert", ["MAP_NOT_FOUND"])
		return

	if not _character_service.move_character(sender_id, direction, map):
		_network.exec(sender_id, &"correct_movement", [character.cell, character.facing])
		return

	var targets: Array = _character_service.get_peers_in_map(map.id)
	targets.erase(sender_id)

	if not targets.is_empty():
		_network.exec(targets, &"move_character", [sender_id, direction])

	if map.has_warp(character.cell):
		await _apply_warp(sender_id, character, map)


## Atualiza os dados do mapa atual para um administrador.
func update_map(identifier: String, bgm: String, bgs: String, size: Vector2i, collisions: Array, warps: Array) -> void:
	var sender_id: int = _network.sender_id()

	var account: Account = _auth_service.get_account(sender_id)
	if account == null or not account.is_admin():
		_network.exec(sender_id, &"alert", ["UNAUTHORIZED"])
		return

	var character: Character = _character_service.get_character(sender_id)
	if character == null:
		return

	if not _map_service.has_map(character.map):
		_network.exec(sender_id, &"alert", ["MAP_NOT_FOUND"])
		return

	var success: bool = await _map_service.update_map(
		character.map,
		identifier,
		bgm,
		bgs,
		size,
		collisions,
		warps
	)

	if not success:
		_network.exec(sender_id, &"alert", ["MAP_UPDATE_FAILED"])
		return

	_network.exec(sender_id, &"alert", ["MAP_UPDATED"])


## Aplica a passagem encontrada para outro mapa.
func _apply_warp(peer_id: int, character: Character, current_map: Map) -> void:
	var warp: Dictionary = _map_service.validate_warp(current_map.id, character.cell)
	if warp.is_empty():
		return

	_leave_map(peer_id)

	var success: bool = await _character_service.warp_character(
		peer_id,
		warp["to_map_id"],
		warp["to_cell"],
		warp["to_facing"]
	)

	if not success:
		return

	var new_map: Map = _map_service.get_map(warp["to_map_id"])
	if new_map == null:
		return

	_network.exec(peer_id, &"warp_map", [new_map.id])

	_send_map_data(peer_id, new_map)


## Envia os dados de um mapa e os personagens presentes nele.
func _send_map_data(peer_id: int, map: Map) -> void:
	var targets: Array = _character_service.get_peers_in_map(map.id)
	targets.erase(peer_id)

	var characters: Array = []
	for target_id in targets:
		var other: Character = _character_service.get_character(target_id)
		if other:
			var data: Array = other.to_array()
			data[0] = target_id
			characters.append(data)

	var map_data: Array = map.to_array()
	map_data.append(characters)

	_network.exec(peer_id, &"map_data", map_data)


## Notifica o jogador e os demais jogadores sobre sua entrada no mapa.
func _enter_map(peer_id: int) -> void:
	var character: Character = _character_service.get_character(peer_id)
	if character == null:
		return

	var character_data: Array = character.to_array()
	character_data[0] = peer_id

	_network.exec(peer_id, &"character_data", [character_data])

	var targets: Array = _character_service.get_peers_in_map(character.map)
	targets.erase(peer_id)

	if not targets.is_empty():
		_network.exec(targets, &"character_to_characters", [character_data])


## Notifica os demais jogadores sobre a saída de um jogador.
func _leave_map(peer_id: int) -> void:
	if not _character_service.has_character(peer_id):
		return

	var character: Character = _character_service.get_character(peer_id)

	var targets: Array = _character_service.get_peers_in_map(character.map)
	targets.erase(peer_id)

	if not targets.is_empty():
		_network.exec(targets, &"character_left", [peer_id])
