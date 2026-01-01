extends Repository
class_name AccountRepository


var sha256: Sha256


func _create_table() -> Error:
	var query: String = '''
	CREATE TABLE IF NOT EXISTS accounts (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		identifier TEXT NOT NULL UNIQUE,
		password TEXT NOT NULL,
		created_at INTEGER NOT NULL,
		updated_at INTEGER NOT NULL
	);
	'''

	var result: Array = await _db_connection.exec(query, []).done
	var parsed: Dictionary = _parse_result(result)

	var status: Error = parsed.get("status", FAILED)
	if status == FAILED:
		var message: String = parsed.get("message", "Erro desconhecido.")
		push_error(
			"[DATABASE] Erro ao criar tabela accounts: %s" % message
		)
		return FAILED

	return OK


func sign_up(identifier: String, password: String, version: Vector3i) -> Dictionary:
	if version != Constants.VERSION:
		return {
			"status": FAILED,
			"message": "Ops, o cliente está desatualizado, por favor atualize!"
		}

	sha256 = Sha256.new()

	var hashed_password: String = sha256.hash(password)
	var now = int(Time.get_unix_time_from_system())

	var query: String = '''
		INSERT INTO accounts (identifier, password, created_at, updated_at)
		VALUES (?, ?, ?, ?);
	'''

	var result: Array = await _db_connection.exec(
		query, [identifier, hashed_password, now, now]
	).done

	var parsed: Dictionary = _parse_result(result)
	var status: Error = parsed.get("status", FAILED)

	if status == FAILED:
		var message: String = parsed.get("message", "Erro desconhecido.")
		var code: int = parsed.get("code", 0)
		if code == SQLiteCodes.CONSTRAINT_UNIQUE:
			return {
				"status": FAILED,
				"message": "Ops, já existe uma conta com esse identificador."
			}
		return {
			"status": FAILED,
			"message": "Erro ao criar conta: %s" % message
		}

	return {
		"status": OK,
		"message": "Conta criada com sucesso."
	}


func sign_in(identifier: String, password: String, version: Vector3i) -> Dictionary:
	if version != Constants.VERSION:
		return {
			"status": FAILED,
			"message": "Ops, o cliente está desatualizado, por favor atualize!"
		}

	sha256 = Sha256.new()

	var query: String = '''
        SELECT id, password FROM accounts WHERE identifier = ?;
    '''

	var result: Array = await _db_connection.fetch(query, [identifier]).done

	var parsed: Dictionary = _parse_result(result)
	var status: Error = parsed.get("status", FAILED)

	print(parsed)

	if status != OK or parsed.data.size() == 0:
		return {
			"status": FAILED,
			"message": "Ops, A conta não foi encontrada."
		}

	var account_row: Array = parsed.data[0]
	var db_password: String = account_row[1]

	if not sha256.verify(password, db_password):
		return {
			"status": FAILED,
			"message": "Senha incorreta."
		}

	return {
		"status": OK,
		"message": "Login realizado com sucesso.",
	}
