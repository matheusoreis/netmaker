extends RefCounted
class_name AccountModule


## Contas carregadas na memória
var _accounts: Dictionary[int, Account] = {}


## Adiciona uma conta ao peer.
func add(peer_id: int, account: Account) -> void:
	if has(peer_id):
		return

	_accounts[peer_id] = account


## Remove a conta de um peer.
func remove(peer_id: int) -> void:
	if not has(peer_id):
		return

	_accounts.erase(peer_id)


## Retorna a conta de um peer.
func account(peer_id: int) -> Account:
	return _accounts.get(peer_id)


## Verifica se um peer possui uma conta.
func has(peer_id: int) -> bool:
	return _accounts.has(peer_id)


## Retorna a quantidade de contas.
func count() -> int:
	return _accounts.size()


## Retorna todas as contas.
func all() -> Array[Account]:
	return _accounts.values()
