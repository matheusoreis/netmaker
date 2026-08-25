extends RefCounted
class_name AuthModule


var _accounts: Dictionary[int, Account] = {}


func add(peer_id: int, account: Account) -> void:
	if has(peer_id):
		return
	_accounts[peer_id] = account


func remove(peer_id: int) -> void:
	if not has(peer_id):
		return
	_accounts.erase(peer_id)


func account(peer_id: int) -> Account:
	return _accounts.get(peer_id)


func has(peer_id: int) -> bool:
	return _accounts.has(peer_id)


func count() -> int:
	return _accounts.size()


func all() -> Array[Account]:
	return _accounts.values()


func get_peer_by_account_id(account_id: int) -> int:
	for peer_id: int in _accounts:
		if _accounts[peer_id].id == account_id:
			return peer_id
	return -1


func clear() -> void:
	_accounts.clear()
