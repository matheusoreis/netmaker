extends RefCounted
class_name MapRepository


var _database: Database


func _init(database: Database) -> void:
	_database = database

	if database:
		setup_schema()


func setup_schema() -> void:
	_database.exec("""
		CREATE TABLE IF NOT EXISTS maps (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			identifier TEXT NOT NULL,
			bgm TEXT NOT NULL,
			bgs TEXT NOT NULL,
			size_x INTEGER NOT NULL,
			size_y INTEGER NOT NULL,
			created_at INTEGER NOT NULL,
			updated_at INTEGER NOT NULL
		)
	""")

	_database.exec("""
		CREATE TABLE IF NOT EXISTS map_collisions (
			map_id INTEGER NOT NULL,
			cell_x INTEGER NOT NULL,
			cell_y INTEGER NOT NULL,
			flag INTEGER NOT NULL,
			PRIMARY KEY (map_id, cell_x, cell_y),
			FOREIGN KEY (map_id) REFERENCES maps(id) ON DELETE CASCADE
		)
	""")

	_database.exec("""
		CREATE INDEX IF NOT EXISTS idx_map_collisions_map ON map_collisions(map_id)
	""")


func get_all_maps() -> Array[Models.MapModel]:
	var rows: Array[Models] = await _database.rows(
		"SELECT id, identifier, bgm, bgs, size_x, size_y, created_at, updated_at FROM maps ORDER BY id",
		[],
		Models.MapModel
	)

	var maps: Array[Models.MapModel] = []
	for row in rows:
		maps.append(row as Models.MapModel)

	return maps


func get_map(map_id: int) -> Models.MapModel:
	var model: Models = await _database.row(
		"SELECT id, identifier, bgm, bgs, size_x, size_y, created_at, updated_at FROM maps WHERE id = ?",
		[map_id],
		Models.MapModel
	)

	return model as Models.MapModel


func get_collisions(map_id: int) -> Dictionary[Vector2i, int]:
	var result: Array[Models] = await _database.rows(
		"SELECT cell_x, cell_y, flag FROM map_collisions WHERE map_id = ?",
		[map_id],
		Models.MapCollisionModel
	)

	var collisions: Dictionary[Vector2i, int] = {}
	for row in result:
		var model: Models.MapCollisionModel = row as Models.MapCollisionModel
		var cell: Vector2i = Vector2i(model.cell_x, model.cell_y)
		collisions[cell] = model.flag

	return collisions


func create_map(id: int, identifier: String, bgm: String, bgs: String, size: Vector2i) -> bool:
	var now: int = _database.now()

	var result: Error = await _database.exec(
		"INSERT INTO maps (id, identifier, bgm, bgs, size_x, size_y, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
		[id, identifier, bgm, bgs, size.x, size.y, now, now]
	)

	return result == OK


func update_map(id: int, identifier: String, bgm: String, bgs: String, size: Vector2i) -> bool:
	var now: int = _database.now()

	var result: Error = await _database.exec(
		"UPDATE maps SET identifier = ?, bgm = ?, bgs = ?, size_x = ?, size_y = ?, updated_at = ? WHERE id = ?",
		[identifier, bgm, bgs, size.x, size.y, now, id]
	)

	return result == OK


func update_collisions(map_id: int, collisions: Dictionary[Vector2i, int]) -> bool:
	var delete_result: Error = await _database.exec(
		"DELETE FROM map_collisions WHERE map_id = ?",
		[map_id]
	)

	if delete_result != OK:
		return false

	if collisions.is_empty():
		return true

	for cell in collisions:
		var flag: int = collisions[cell]
		var result: Error = await _database.exec(
			"INSERT INTO map_collisions (map_id, cell_x, cell_y, flag) VALUES (?, ?, ?, ?)",
			[map_id, cell.x, cell.y, flag]
		)
		if result != OK:
			return false

	return true


func map_exists(map_id: int) -> bool:
	var result: Variant = await _database.scalar(
		"SELECT COUNT(*) FROM maps WHERE id = ?",
		[map_id]
	)

	return result != null and result > 0


func delete_map(map_id: int) -> bool:
	var result: Error = await _database.exec(
		"DELETE FROM maps WHERE id = ?",
		[map_id]
	)

	return result == OK
