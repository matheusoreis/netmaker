extends RefCounted
class_name AuthHandler


var _network: Network
var _auth_service: AuthService


func _init(network: Network, auth_service: AuthService) -> void:
	_network = network
	_auth_service = auth_service


func register() -> Error:
	return _network.register([
		sign_in,
		sign_up
	])


func unregister() -> Error:
	return _network.unregister([
		sign_in,
		sign_up
	])


func sign_in(email: String, password: String) -> void:
	var sender_id: int = _network.sender_id()

	if _auth_service.is_signed_in(sender_id):
		_network.exec(sender_id, &"alert", ["ALREADY_LOGGED_IN"])
		return

	var result: Array = await _auth_service.sign_in(sender_id, email, password)
	if result[0] != OK:
		_network.exec(sender_id, &"alert", [result[1]])
		return

	_network.exec(sender_id, &"sign_in")


func sign_up(email: String, password: String, password_confirm: String) -> void:
	var sender_id: int = _network.sender_id()

	if _auth_service.is_signed_in(sender_id):
		_network.exec(sender_id, &"alert", ["ALREADY_LOGGED_IN"])
		return

	var result: Array = await _auth_service.sign_up(sender_id, email, password, password_confirm)
	if result[0] != OK:
		_network.exec(sender_id, &"alert", [result[1]])
		return

	_network.exec(sender_id, &"sign_up")
