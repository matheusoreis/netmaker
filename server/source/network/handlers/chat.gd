extends RefCounted
class_name ChatHandler


var _network: Network

var _character_service: CharacterService


func _init(network: Network, character_service: CharacterService) -> void:
	_network = network
	_character_service = character_service


func register() -> Error:
	return _network.register([
		chat_local,
		chat_global
	])


func unregister() -> Error:
	return _network.unregister([
		chat_local,
		chat_global
	])


func chat_local(message: String) -> void:
	var sender_id: int = _network.sender_id()

	var character: Character = _character_service.get_character(sender_id)
	if character == null:
		return

	var clean_message: String = _sanitize_message(message)
	if clean_message.is_empty():
		return

	var targets: Array = _character_service.get_peers_in_map(character.map)
	if targets.is_empty():
		return

	_network.exec(targets, &"chat_local", [character.identifier, clean_message])


func chat_global(message: String) -> void:
	var sender_id: int = _network.sender_id()

	var character: Character = _character_service.get_character(sender_id)
	if character == null:
		return

	var clean_message: String = _sanitize_message(message)
	if clean_message.is_empty():
		return

	var targets: Array = _character_service.get_all_peers()
	if targets.is_empty():
		return

	_network.exec(targets, &"chat_global", [character.identifier, clean_message])


func _sanitize_message(message: String) -> String:
	var trimmed: String = message.strip_edges()
	if trimmed.is_empty():
		return ""

	if trimmed.length() > Constants.MAX_CHAT_MESSAGE_LENGTH:
		trimmed = trimmed.substr(0, Constants.MAX_CHAT_MESSAGE_LENGTH)

	return trimmed
