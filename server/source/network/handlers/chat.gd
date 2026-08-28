extends RefCounted
class_name ChatHandler


## Serviço de rede utilizado pelo handler.
var _network: Network

## Serviço responsável pelo gerenciamento dos personagens.
var _character_service: CharacterService


## Cria um handler de chat.
func _init(network: Network, character_service: CharacterService) -> void:
	_network = network
	_character_service = character_service


## Registra os eventos de chat na rede.
func register() -> Error:
	return _network.register([
		chat_local,
		chat_global
	])


## Remove os eventos de chat da rede.
func unregister() -> Error:
	return _network.unregister([
		chat_local,
		chat_global
	])


## Envia uma mensagem para os jogadores do mesmo mapa.
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


## Envia uma mensagem para todos os jogadores conectados.
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


## Remove espaços excedentes e limita o tamanho da mensagem.
func _sanitize_message(message: String) -> String:
	var trimmed: String = message.strip_edges()
	if trimmed.is_empty():
		return ""

	if trimmed.length() > Constants.MAX_CHAT_MESSAGE_LENGTH:
		trimmed = trimmed.substr(0, Constants.MAX_CHAT_MESSAGE_LENGTH)

	return trimmed
