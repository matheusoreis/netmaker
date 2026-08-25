extends RefCounted
class_name MapHandler


var _network: Network

var _auth_service: AuthService
var _character_service: CharacterService
var _map_service: MapService


func _init(network: Network, auth_service: AuthService, character_service: CharacterService, map_service: MapService) -> void:
	_network = network
	_auth_service = auth_service
	_character_service = character_service
	_map_service = map_service


func register() -> Error:
	return _network.register([
		map_data,
		enter_map,
		move_character,
	])


func unregister() -> Error:
	return _network.unregister([
		map_data,
		enter_map,
		move_character,
	])


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

	var targets: Array = _character_service.get_peers_in_map(map.id)
	targets.erase(sender_id)

	var characters: Array = []
	for target_id in targets:
		var other: Character = _character_service.get_character(target_id)
		if other:
			var data: Array = other.to_array()
			data[0] = target_id
			characters.append(data)

	var map_data: Array = map.to_array()
	map_data.append(characters)

	_network.exec(sender_id, &"map_data", map_data)


func enter_map() -> void:
	var sender_id: int = _network.sender_id()

	if not _character_service.has_character(sender_id):
		_network.exec(sender_id, &"alert", ["NO_CHARACTER_SELECTED"])
		return

	var character: Character = _character_service.get_character(sender_id)
	var character_data: Array = character.to_array()
	character_data[0] = sender_id

	_network.exec(sender_id, &"character_data", [character_data])

	var targets: Array = _character_service.get_peers_in_map(character.map)
	targets.erase(sender_id)

	if not targets.is_empty():
		_network.exec(targets, &"character_to_characters", [character_data])


func leave_map(peer_id: int) -> void:
	if not _character_service.has_character(peer_id):
		return

	var character: Character = _character_service.get_character(peer_id)

	var targets: Array = _character_service.get_peers_in_map(character.map)
	targets.erase(peer_id)

	if not targets.is_empty():
		_network.exec(targets, &"character_left", [peer_id])


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
