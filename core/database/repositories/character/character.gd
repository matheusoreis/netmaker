extends Repository
class_name CharacterRepository


func _create_table() -> Error:
	var query: String = '''
	CREATE TABLE IF NOT EXISTS characters (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		account_id INTEGER NOT NULL,
		vocation_id INTEGER NOT NULL,
		map_id INTEGER NOT NULL,
		identifier TEXT NOT NULL UNIQUE,
		sprite TEXT NOT NULL,
		created_at INTEGER NOT NULL,
		updated_at INTEGER NOT NULL,
		FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE,
		FOREIGN KEY (vocation_id) REFERENCES vocations(id) ON DELETE RESTRICT,
		FOREIGN KEY (map_id) REFERENCES maps(id) ON DELETE RESTRICT
	);
	'''

	var result: Array = await _db_connection.exec(query, []).done
	var parsed: Dictionary = _parse_result(result)

	var status: Error = parsed.get("status", FAILED)
	if status == FAILED:
		var message: String = parsed.get("message", "Erro desconhecido.")
		push_error(
			"[DATABASE] Erro ao criar tabela characters: %s" % message
		)
		return FAILED

	return OK


func _create_indexes() -> Error:
	var queries = [
		"CREATE INDEX IF NOT EXISTS idx_characters_account_id ON characters(account_id);",
		"CREATE INDEX IF NOT EXISTS idx_characters_vocation_id ON characters(vocation_id);",
		"CREATE INDEX IF NOT EXISTS idx_characters_map_id ON characters(map_id);"
	]

	for query in queries:
		var result: Array = await _db_connection.exec(query, []).done
		var parsed: Dictionary = _parse_result(result)

		var status: Error = parsed.get("status", FAILED)
		if status == FAILED:
			var message: String = parsed.get("message", "Erro desconhecido.")
			push_error(
				"[DATABASE] Erro ao criar índices em characters: %s" % message
			)
			return FAILED

	return OK
