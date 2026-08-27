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
		CREATE TABLE IF NOT EXISTS map_warps (
			map_id INTEGER NOT NULL,
			from_cell_x INTEGER NOT NULL,
			from_cell_y INTEGER NOT NULL,
			to_map_id INTEGER NOT NULL,
			to_cell_x INTEGER NOT NULL,
			to_cell_y INTEGER NOT NULL,
			to_facing_x INTEGER NOT NULL,
			to_facing_y INTEGER NOT NULL,
			PRIMARY KEY (map_id, from_cell_x, from_cell_y),
			FOREIGN KEY (map_id) REFERENCES maps(id) ON DELETE CASCADE,
			FOREIGN KEY (to_map_id) REFERENCES maps(id) ON DELETE CASCADE
		)
	""")

	_database.exec("""
		CREATE INDEX IF NOT EXISTS idx_map_warps_map ON map_warps(map_id)
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


func update_collisions(map_id: int, collisions: Array) -> bool:
	var delete_result: Error = await _database.exec(
		"DELETE FROM map_collisions WHERE map_id = ?",
		[map_id]
	)

	if delete_result != OK:
		return false

	if collisions.is_empty():
		return true

	for entry in collisions:
		var cell: Vector2i = entry[0]
		var flag: int = entry[1]

		var result: Error = await _database.exec(
			"INSERT INTO map_collisions (map_id, cell_x, cell_y, flag) VALUES (?, ?, ?, ?)",
			[map_id, cell.x, cell.y, flag]
		)
		if result != OK:
			return false

	return true



func get_warps(map_id: int) -> Dictionary[Vector2i, Dictionary]:
	var result: Array[Models] = await _database.rows(
		"SELECT map_id, from_cell_x, from_cell_y, to_map_id, to_cell_x, to_cell_y, to_facing_x, to_facing_y FROM map_warps WHERE map_id = ?",
		[map_id],
		Models.MapWarpModel
	)

	var warps: Dictionary[Vector2i, Dictionary] = {}
	for row in result:
		var model: Models.MapWarpModel = row as Models.MapWarpModel
		var cell: Vector2i = Vector2i(model.from_cell_x, model.from_cell_y)
		warps[cell] = {
			"to_map_id": model.to_map_id,
			"to_cell": Vector2i(model.to_cell_x, model.to_cell_y),
			"to_facing": Vector2i(model.to_facing_x, model.to_facing_y)
		}

	return warps


func get_warp_by_cell(map_id: int, cell_x: int, cell_y: int) -> Dictionary:
	var model: Models = await _database.row(
		"SELECT map_id, from_cell_x, from_cell_y, to_map_id, to_cell_x, to_cell_y, to_facing_x, to_facing_y FROM map_warps WHERE map_id = ? AND from_cell_x = ? AND from_cell_y = ?",
		[map_id, cell_x, cell_y],
		Models.MapWarpModel
	)

	if model == null:
		return {}

	var warp: Models.MapWarpModel = model as Models.MapWarpModel
	return {
		"to_map_id": warp.to_map_id,
		"to_cell": Vector2i(warp.to_cell_x, warp.to_cell_y),
		"to_facing": Vector2i(warp.to_facing_x, warp.to_facing_y)
	}


func create_warp(map_id: int, from_cell: Vector2i, to_map_id: int, to_cell: Vector2i, to_facing: Vector2i) -> bool:
	var result: Error = await _database.exec(
		"INSERT INTO map_warps (map_id, from_cell_x, from_cell_y, to_map_id, to_cell_x, to_cell_y, to_facing_x, to_facing_y) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
		[map_id, from_cell.x, from_cell.y, to_map_id, to_cell.x, to_cell.y, to_facing.x, to_facing.y]
	)

	return result == OK


func delete_warp(map_id: int, cell_x: int, cell_y: int) -> bool:
	var result: Error = await _database.exec(
		"DELETE FROM map_warps WHERE map_id = ? AND from_cell_x = ? AND from_cell_y = ?",
		[map_id, cell_x, cell_y]
	)
	return result == OK


func delete_warps_by_map(map_id: int) -> bool:
	var result: Error = await _database.exec(
		"DELETE FROM map_warps WHERE map_id = ?",
		[map_id]
	)
	return result == OK


func warp_exists(map_id: int, cell_x: int, cell_y: int) -> bool:
	var result: Variant = await _database.scalar(
		"SELECT COUNT(*) FROM map_warps WHERE map_id = ? AND from_cell_x = ? AND from_cell_y = ?",
		[map_id, cell_x, cell_y]
	)
	return result != null and result > 0


func update_warps(map_id: int, warps: Array) -> bool:
	var delete_result: Error = await _database.exec(
		"DELETE FROM map_warps WHERE map_id = ?",
		[map_id]
	)

	if delete_result != OK:
		return false

	if warps.is_empty():
		return true

	for entry in warps:
		var from_cell: Vector2i = entry[0]
		var to_map_id: int = entry[1]
		var to_cell: Vector2i = entry[2]
		var to_facing: Vector2i = entry[3]

		var result: Error = await _database.exec(
			"INSERT INTO map_warps (map_id, from_cell_x, from_cell_y, to_map_id, to_cell_x, to_cell_y, to_facing_x, to_facing_y) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
			[map_id, from_cell.x, from_cell.y, to_map_id, to_cell.x, to_cell.y, to_facing.x, to_facing.y]
		)
		if result != OK:
			return false

	return true
