extends RefCounted
class_name Database

var _aslet: Aslet
var _conn: AsletConn


func initialize(db_path: String, db_filename: String) -> AsletConn:
	DirAccess.make_dir_recursive_absolute(db_path)

	var full_path := "%s%s.db" % [db_path, db_filename]
	print("[DATABASE] Abrindo banco: %s" % full_path)

	_aslet = Aslet.new()
	var result := _aslet.open(full_path).wait()

	if result.is_empty() or result[0] != OK:
		push_error("[DATABASE] Falha ao abrir banco.")
		return null

	_conn = result[1]

	_conn.exec("PRAGMA foreign_keys = ON;", []).wait()
	_conn.exec("PRAGMA journal_mode = WAL;", []).wait()

	print("[DATABASE] Banco de dados aberto em: %s" % full_path)

	return _conn


func poll(poll_time: int) -> void:
	if _aslet:
		_aslet.poll(poll_time)
