extends RefCounted
class_name AuthModule


## Contas autenticadas indexadas pelo identificador do peer.
var _accounts: Dictionary[int, Account] = {}


## Adiciona uma conta autenticada ao módulo.
func add(peer_id: int, account: Account) -> void:
	if has(peer_id):
		return
	_accounts[peer_id] = account


## Remove a conta associada a um peer.
func remove(peer_id: int) -> void:
	if not has(peer_id):
		return
	_accounts.erase(peer_id)


## Retorna a conta associada a um peer.
func account(peer_id: int) -> Account:
	return _accounts.get(peer_id)


## Indica se existe uma conta associada ao peer.
func has(peer_id: int) -> bool:
	return _accounts.has(peer_id)


## Retorna a quantidade de contas autenticadas.
func count() -> int:
	return _accounts.size()


## Retorna todas as contas autenticadas.
func all() -> Array[Account]:
	return _accounts.values()


## Retorna o peer associado ao identificador da conta.
func get_peer_by_account_id(account_id: int) -> int:
	for peer_id: int in _accounts:
		if _accounts[peer_id].id == account_id:
			return peer_id
	return -1


## Remove todas as contas autenticadas.
func clear() -> void:
	_accounts.clear()
