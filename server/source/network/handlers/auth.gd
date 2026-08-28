extends RefCounted
class_name AuthHandler


## Serviço de rede utilizado pelo handler.
var _network: Network

## Serviço responsável pela autenticação das contas.
var _auth_service: AuthService


## Cria um handler de autenticação.
func _init(network: Network, auth_service: AuthService) -> void:
	_network = network
	_auth_service = auth_service


## Registra os eventos de autenticação na rede.
func register() -> Error:
	return _network.register([
		sign_in,
		sign_up
	])


## Remove os eventos de autenticação da rede.
func unregister() -> Error:
	return _network.unregister([
		sign_in,
		sign_up
	])


## Verifica se a versão do cliente é compatível com o servidor.
func _is_version_valid(major_version: int, minor_version: int, revision_version: int) -> bool:
	return (
		major_version == Constants.MAJOR_VERSION
		and minor_version == Constants.MINOR_VERSION
		and revision_version == Constants.REVISION_VERSION
	)


## Valida a versão e o estado de autenticação do cliente.
func _validate_request(major_version: int, minor_version: int, revision_version: int) -> int:
	var sender_id: int = _network.sender_id()

	if not _is_version_valid(major_version, minor_version, revision_version):
		_network.exec(sender_id, &"alert", ["OUTDATED_CLIENT"])
		return -1

	if _auth_service.is_signed_in(sender_id):
		_network.exec(sender_id, &"alert", ["ALREADY_LOGGED_IN"])
		return -1

	return sender_id


## Processa uma solicitação de login.
func sign_in(email: String, password: String, major_version: int, minor_version: int, revision_version: int) -> void:
	var sender_id := _validate_request(major_version, minor_version, revision_version)
	if sender_id == -1:
		return

	var result: Array = await _auth_service.sign_in(sender_id, email, password)
	if result[0] != OK:
		_network.exec(sender_id, &"alert", [result[1]])
		return

	_network.exec(sender_id, &"sign_in")


## Processa uma solicitação de criação de conta.
func sign_up(email: String, password: String, password_confirm: String, major_version: int, minor_version: int, revision_version: int) -> void:
	var sender_id := _validate_request(major_version, minor_version, revision_version)
	if sender_id == -1:
		return

	var result: Array = await _auth_service.sign_up(sender_id, email, password, password_confirm)
	if result[0] != OK:
		_network.exec(sender_id, &"alert", [result[1]])
		return

	_network.exec(sender_id, &"sign_up")
