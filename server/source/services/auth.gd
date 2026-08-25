extends RefCounted
class_name AuthService


var _auth_repository: AuthRepository
var _auth_module: AuthModule


func _init(auth_repository: AuthRepository, auth_module: AuthModule) -> void:
	_auth_repository = auth_repository
	_auth_module = auth_module


func is_signed_in(peer_id: int) -> bool:
	return _auth_module.has(peer_id)


func get_account(peer_id: int) -> Account:
	return _auth_module.account(peer_id)


func sign_in(peer_id: int, email: String, password: String) -> Array:
	var result: Array = await _auth_repository.sign_in(email, password)
	if result[0] != OK:
		return result

	var account: Account = result[1] as Account

	_auth_module.add(peer_id, account)
	await _auth_repository.update_access_at(account.id)

	return [OK, account]


func sign_up(peer_id: int, email: String, password: String, password_confirm: String) -> Array:
	var result: Array = await _auth_repository.sign_up(email, password, password_confirm)
	if result[0] != OK:
		return result

	var account: Account = result[1] as Account

	_auth_module.add(peer_id, account)

	return [OK, account]


func sign_out(peer_id: int) -> void:
	if not _auth_module.has(peer_id):
		return

	var account: Account = _auth_module.account(peer_id)
	await _auth_repository.update_access_at(account.id)

	_auth_module.remove(peer_id)


func ban_account(account_id: int) -> int:
	await _auth_repository.ban_account(account_id)

	var peer_id: int = _auth_module.get_peer_by_account_id(account_id)
	if peer_id != -1:
		_auth_module.remove(peer_id)

	return peer_id


func unban_account(account_id: int) -> void:
	await _auth_repository.unban_account(account_id)


func remove_account(peer_id: int) -> void:
	if not _auth_module.has(peer_id):
		return
	_auth_module.remove(peer_id)
