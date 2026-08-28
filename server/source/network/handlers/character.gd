extends RefCounted
class_name CharacterHandler


## Serviço de rede utilizado pelo handler.
var _network: Network

## Serviço responsável pela autenticação das contas.
var _auth_service: AuthService
## Serviço responsável pelo gerenciamento dos personagens.
var _character_service: CharacterService


## Cria um handler de personagens.
func _init(network: Network, auth_service: AuthService, character_service: CharacterService) -> void:
	_network = network

	_auth_service = auth_service
	_character_service = character_service


## Registra os eventos de personagens na rede.
func register() -> Error:
	return _network.register([
		list_characters,
		create_character,
		delete_character,
		select_character
	])


## Remove os eventos de personagens da rede.
func unregister() -> Error:
	return _network.unregister([
		list_characters,
		create_character,
		delete_character,
		select_character
	])


## Envia a lista de personagens da conta solicitante.
func list_characters() -> void:
	var sender_id: int = _network.sender_id()

	var account: Account = _auth_service.get_account(sender_id)
	if account == null:
		_network.exec(sender_id, &"alert", ["NOT_LOGGED_IN"])
		return

	var characters_data: Array = await _character_service.list_characters(account.id)

	_network.exec(sender_id, &"list_characters", [characters_data])


## Cria um personagem para a conta solicitante.
func create_character(identifier: String, spritesheet: String) -> void:
	var sender_id: int = _network.sender_id()

	var account: Account = _auth_service.get_account(sender_id)
	if account == null:
		_network.exec(sender_id, &"alert", ["NOT_LOGGED_IN"])
		return

	var result: Array = await _character_service.create_character(account.id, identifier, spritesheet)
	var error_code: int = result[0]
	var data = result[1]

	if error_code != OK:
		_network.exec(sender_id, &"alert", [data])
		return

	_network.exec(sender_id, &"create_character")


## Exclui um personagem da conta solicitante.
func delete_character(character_id: int) -> void:
	var sender_id: int = _network.sender_id()

	var account: Account = _auth_service.get_account(sender_id)
	if account == null:
		_network.exec(sender_id, &"alert", ["NOT_LOGGED_IN"])
		return

	if _character_service.is_character_online(character_id):
		_network.exec(sender_id, &"alert", ["CHARACTER_ONLINE"])
		return

	var result: Array = await _character_service.delete_character(sender_id, character_id, account.id)
	var error_code: int = result[0]
	var data = result[1]

	if error_code != OK:
		_network.exec(sender_id, &"alert", [data])
		return

	_network.exec(sender_id, &"delete_character")


## Seleciona um personagem para a conexão solicitante.
func select_character(character_id: int) -> void:
	var sender_id: int = _network.sender_id()

	var account: Account = _auth_service.get_account(sender_id)
	if account == null:
		_network.exec(sender_id, &"alert", ["NOT_LOGGED_IN"])
		return

	if _character_service.is_character_online(character_id):
		_network.exec(sender_id, &"alert", ["CHARACTER_ALREADY_ONLINE"])
		return

	var result: Array = await _character_service.select_character(sender_id, character_id, account.id)
	var error_code: int = result[0]
	var data = result[1]

	if error_code != OK:
		_network.exec(sender_id, &"alert", [data])
		return

	_network.exec(sender_id, &"select_character")
