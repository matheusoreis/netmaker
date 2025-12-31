extends Node
class_name Repository


var _db_connection: AsletConn


func initialize(db_connection: AsletConn) -> Error:
	_db_connection = db_connection

	var repo_name: StringName = get_script().get_global_name()
	print("[DATABASE] Iniciando o repositório %s" % repo_name)

	@warning_ignore("redundant_await")
	var err: Error = await _create_table()
	if err != OK:
		push_error("[DATABASE] Falha ao criar tabela em %s" % repo_name)
		return err

	@warning_ignore("redundant_await")
	err = await _create_indexes()
	if err != OK:
		push_error("[DATABASE] Falha ao criar índices em %s" % repo_name)
		return err

	print("[DATABASE] Repositório %s iniciado." % repo_name)
	return OK


func _create_table() -> Error:
	return OK


func _create_indexes() -> Error:
	return OK


func _row_to_dictionary(row: Array, columns: Array) -> Dictionary:
	var dict := {}
	for i in range(columns.size()):
		dict[columns[i]] = row[i]
	return dict


func _parse_result(result: Array) -> Dictionary:
	if result.is_empty():
		return {
			"status": FAILED,
			"data": "Banco não retornou resposta."
		}

	var status = result[0]
	var data = null

	if result.size() > 1:
		data = result[1]

	var dict = {
		"status": status,
		"data": data
	}

	if result.size() > 2 and result[2] != "":
		dict["message"] = result[2]

	return dict
