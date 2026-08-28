extends RefCounted
class_name AuthRepository


var _database: Database


## Configura o banco de dados e cria o esquema de autenticação.
func setup(database: Database) -> void:
	_database = database

	if _database:
		await setup_schema()


## Cria a tabela de contas e seus índices.
func setup_schema() -> void:
	await _database.exec("""
		CREATE TABLE IF NOT EXISTS accounts (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			email TEXT NOT NULL UNIQUE,
			password TEXT NOT NULL,
			role INTEGER NOT NULL DEFAULT 0,
			access_at INTEGER NOT NULL,
			banned_at INTEGER NOT NULL DEFAULT 0,
			created_at INTEGER NOT NULL,
			updated_at INTEGER NOT NULL
		)
	""")

	await _database.exec("""
		CREATE INDEX IF NOT EXISTS idx_accounts_email ON accounts(email)
	""")


## Autentica uma conta usando o e-mail e a senha informados.
func sign_in(email: String, password: String) -> Array:
	if not _is_email_valid(email):
		return [ERR_INVALID_PARAMETER, "INVALID_EMAIL"]

	if not _is_password_valid(password):
		return [ERR_INVALID_PARAMETER, "INVALID_PASSWORD"]

	var model: Models.AccountModel = await _database.row(
		"SELECT id, email, password, role, access_at, banned_at, created_at, updated_at FROM accounts WHERE email = ?",
		[email],
		Models.AccountModel
	)

	if model == null:
		return [ERR_DOES_NOT_EXIST, "ACCOUNT_NOT_FOUND"]

	if model.banned_at > 0:
		return [ERR_UNAUTHORIZED, "ACCOUNT_BANNED"]

	if not Sha256.new().verify_value(password, model.password):
		return [ERR_UNAUTHORIZED, "INCORRECT_PASSWORD"]

	var account: Account = Account.new(
		model.id,
		model.email,
		model.password,
		model.role,
		model.access_at,
		model.banned_at,
		model.created_at,
		model.updated_at
	)

	return [OK, account]


## Cria uma nova conta após validar seus dados.
func sign_up(email: String, password: String, password_confirm: String) -> Array:
	if not _is_email_valid(email):
		return [ERR_INVALID_PARAMETER, "INVALID_EMAIL"]

	if not _is_password_valid(password):
		return [ERR_INVALID_PARAMETER, "INVALID_PASSWORD"]

	if password != password_confirm:
		return [ERR_INVALID_DATA, "PASSWORDS_DO_NOT_MATCH"]

	var existing: Variant = await _database.scalar(
		"SELECT COUNT(*) FROM accounts WHERE email = ?",
		[email]
	)

	if existing != null and existing > 0:
		return [ERR_ALREADY_EXISTS, "EMAIL_ALREADY_REGISTERED"]

	var hashed: String = Sha256.new().hash_value(password)
	var now: int = _database.now()

	var result: Error = await _database.exec(
		"INSERT INTO accounts (email, password, role, access_at, banned_at, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?)",
		[email, hashed, 0, now, 0, now, now]
	)

	if result != OK:
		return [ERR_DATABASE_CANT_WRITE, "INTERNAL_ERROR"]

	var model: Models.AccountModel = await _database.row(
		"SELECT id, email, password, role, access_at, banned_at, created_at, updated_at FROM accounts WHERE email = ?",
		[email],
		Models.AccountModel
	)

	if model == null:
		return [ERR_DOES_NOT_EXIST, "INTERNAL_ERROR"]

	await update_updated_at(model.id)

	var account: Account = Account.new(
		model.id,
		model.email,
		model.password,
		model.role,
		model.access_at,
		model.banned_at,
		model.created_at,
		model.updated_at
	)

	return [OK, account]


## Atualiza o horário do último acesso da conta.
func update_access_at(account_id: int) -> void:
	await _database.exec(
		"UPDATE accounts SET access_at = ? WHERE id = ?",
		[_database.now(), account_id]
	)


## Atualiza o horário da última alteração da conta.
func update_updated_at(account_id: int) -> void:
	await _database.exec(
		"UPDATE accounts SET updated_at = ? WHERE id = ?",
		[_database.now(), account_id]
	)


## Bane uma conta registrando o horário do banimento.
func ban_account(account_id: int) -> void:
	await _database.exec(
		"UPDATE accounts SET banned_at = ? WHERE id = ?",
		[_database.now(), account_id]
	)


## Remove o banimento de uma conta.
func unban_account(account_id: int) -> void:
	await _database.exec(
		"UPDATE accounts SET banned_at = 0 WHERE id = ?",
		[account_id]
	)


## Indica se uma conta está banida.
func is_account_banned(account_id: int) -> bool:
	var result: Variant = await _database.scalar(
		"SELECT banned_at FROM accounts WHERE id = ?",
		[account_id]
	)

	return result != null and result > 0


## Valida o formato de um endereço de e-mail.
func _is_email_valid(email: String) -> bool:
	return RegEx.create_from_string(Constants.EMAIL_REGEX).search(email) != null


## Valida o formato de uma senha.
func _is_password_valid(password: String) -> bool:
	return RegEx.create_from_string(Constants.PASSWORD_REGEX).search(password) != null
