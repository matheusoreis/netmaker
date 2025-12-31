extends Repository
class_name VocationRepository


func _create_table() -> Error:
	var query: String = '''
	CREATE TABLE IF NOT EXISTS vocations (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		identifier TEXT NOT NULL UNIQUE,
		starting_map_id INTEGER NOT NULL,
		starting_position_x INTEGER NOT NULL,
		starting_position_y INTEGER NOT NULL,
		created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
		updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
		FOREIGN KEY (starting_map_id) REFERENCES maps(id) ON DELETE RESTRICT
	);
	'''

	var result: Array = await _db_connection.exec(query, []).done
	var parsed: Dictionary = _parse_result(result)

	var status: Error = parsed.get("status", FAILED)
	if status == FAILED:
		var message: String = parsed.get("message", "Erro desconhecido.")
		push_error(
			"[DATABASE] Erro ao criar tabela vocations: %s" % message
		)
		return FAILED

	return OK


func _create_indexes() -> Error:
	var queries = [
		"CREATE INDEX IF NOT EXISTS idx_vocations_starting_map_id ON vocations(starting_map_id)"
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
