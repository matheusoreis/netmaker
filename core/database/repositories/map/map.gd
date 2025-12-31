extends Repository
class_name MapRepository


func _create_table() -> Error:
	var query: String = '''
	CREATE TABLE IF NOT EXISTS maps (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		identifier TEXT NOT NULL UNIQUE,
		node TEXT NOT NULL,
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
			"[DATABASE] Erro ao criar tabela maps: %s" % message
		)
		return FAILED

	return OK
