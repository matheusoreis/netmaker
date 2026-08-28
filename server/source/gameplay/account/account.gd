extends RefCounted
class_name Account


## Identificador da conta.
var id: int

## Endereço de e-mail da conta.
var email: String
## Senha da conta.
var password: String

## Nível de acesso da conta.
var role: int

## Timestamp do último acesso da conta.
var access_at: int
## Timestamp do banimento da conta.
var banned_at: int
## Timestamp de criação da conta.
var created_at: int
## Timestamp da última atualização da conta.
var updated_at: int


## Cria uma conta com os dados informados.
func _init(id: int, email: String, password: String, role: int, access_at: int, banned_at: int, created_at: int, updated_at: int) -> void:
	self.id = id

	self.email = email
	self.password = password

	self.role = role

	self.access_at = access_at
	self.banned_at = banned_at
	self.created_at = created_at
	self.updated_at = updated_at


## Indica se a conta está banida.
func is_banned() -> bool:
	return banned_at > 0


## Indica se a conta possui permissão de administrador.
func is_admin() -> bool:
	return role >= 1


## Indica se a conta possui permissão de moderador.
func is_moderator() -> bool:
	return role >= 2
