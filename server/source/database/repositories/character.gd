extends RefCounted
class_name CharacterRepository


var _database: Database


func _init(database: Database) -> void:
	_database = database

	if database:
		setup_schema()


func setup_schema() -> void:
	_database.exec("""
		CREATE TABLE IF NOT EXISTS characters (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			account INTEGER NOT NULL,
			identifier TEXT NOT NULL,
			spritesheet TEXT NOT NULL,
			map INTEGER NOT NULL,
			cell_x INTEGER NOT NULL,
			cell_y INTEGER NOT NULL,
			facing_x INTEGER NOT NULL,
			facing_y INTEGER NOT NULL,
			access_at INTEGER NOT NULL,
			created_at INTEGER NOT NULL,
			updated_at INTEGER NOT NULL,
			FOREIGN KEY(account) REFERENCES accounts(id) ON DELETE CASCADE,
			FOREIGN KEY(map) REFERENCES maps(id) ON DELETE RESTRICT,
			UNIQUE(account, identifier)
		)
	""")

	_database.exec("""
		CREATE INDEX IF NOT EXISTS idx_characters_account ON characters(account)
	""")

	_database.exec("""
		CREATE INDEX IF NOT EXISTS idx_characters_identifier ON characters(identifier)
	""")

	_database.exec("""
		CREATE INDEX IF NOT EXISTS idx_characters_map ON characters(map)
	""")


func get_characters_by_account(account_id: int) -> Array[Models.CharacterModel]:
	var rows: Array[Models] = await _database.rows(
		"SELECT id, account, identifier, spritesheet, map, cell_x, cell_y, facing_x, facing_y, access_at, created_at, updated_at FROM characters WHERE account = ? ORDER BY id",
		[account_id],
		Models.CharacterModel
	)

	var characters: Array[Models.CharacterModel] = []
	for row in rows:
		characters.append(row as Models.CharacterModel)

	return characters


func get_character_by_id(character_id: int) -> Models.CharacterModel:
	var model: Models = await _database.row(
		"SELECT id, account, identifier, spritesheet, map, cell_x, cell_y, facing_x, facing_y, access_at, created_at, updated_at FROM characters WHERE id = ?",
		[character_id],
		Models.CharacterModel
	)

	return model as Models.CharacterModel


func is_character_owner(character_id: int, account_id: int) -> bool:
	var model: Models = await _database.row(
		"SELECT id FROM characters WHERE id = ? AND account = ?",
		[character_id, account_id],
		Models.CharacterModel
	)

	return model != null


func character_identifier_exists(account_id: int, identifier: String) -> bool:
	var result: Variant = await _database.scalar(
		"SELECT COUNT(*) FROM characters WHERE account = ? AND identifier = ?",
		[account_id, identifier]
	)

	return result > 0


func create_character(account_id: int, identifier: String, spritesheet: String) -> Array:
	if not _is_identifier_valid(identifier):
		return [ERR_INVALID_PARAMETER, "INVALID_IDENTIFIER"]

	if await character_identifier_exists(account_id, identifier):
		return [ERR_ALREADY_EXISTS, "IDENTIFIER_ALREADY_EXISTS"]

	if not Constants.AVALIABLE_SPRITES.has(spritesheet):
		return [ERR_INVALID_PARAMETER, "INVALID_SPRITE"]

	var result: Error = await _database.exec(
		"""
		INSERT INTO characters (account, identifier, spritesheet, map, cell_x, cell_y, facing_x, facing_y, access_at, created_at, updated_at)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
		""",
		[
			account_id,
			identifier,
			spritesheet,
			Constants.START_MAP,
			Constants.START_MAP_POSITION.x,
			Constants.START_MAP_POSITION.y,
			Constants.START_MAP_FACING.x,
			Constants.START_MAP_FACING.y,
			_database.now(),
			_database.now(),
			_database.now()
		]
	)

	if result != OK:
		return [ERR_DATABASE_CANT_WRITE, "DATABASE_ERROR"]

	var model: Models = await _database.row(
		"SELECT id, account, identifier, spritesheet, map, cell_x, cell_y, facing_x, facing_y, access_at, created_at, updated_at FROM characters WHERE account = ? AND identifier = ?",
		[account_id, identifier],
		Models.CharacterModel
	)

	if model == null:
		return [ERR_DOES_NOT_EXIST, "DATABASE_ERROR"]

	return [OK, model as Models.CharacterModel]


func delete_character(character_id: int, account_id: int) -> Array:
	if not await is_character_owner(character_id, account_id):
		return [ERR_UNAUTHORIZED, "NOT_OWNER"]

	var result: Error = await _database.exec(
		"DELETE FROM characters WHERE id = ? AND account = ?",
		[character_id, account_id]
	)

	if result != OK:
		return [ERR_DATABASE_CANT_WRITE, "DATABASE_ERROR"]

	return [OK, null]


func select_character(character_id: int, account_id: int) -> Array:
	if not await is_character_owner(character_id, account_id):
		return [ERR_UNAUTHORIZED, "NOT_OWNER"]

	var model: Models.CharacterModel = await get_character_by_id(character_id)
	if model == null:
		return [ERR_DOES_NOT_EXIST, "CHARACTER_NOT_FOUND"]

	await _database.exec(
		"UPDATE characters SET access_at = ? WHERE id = ?",
		[_database.now(), character_id]
	)

	return [OK, model]


func update_character_position(character_id: int, cell: Vector2i, facing: Vector2i) -> Array:
	var result: Error = await _database.exec(
		"UPDATE characters SET cell_x = ?, cell_y = ?, facing_x = ?, facing_y = ? WHERE id = ?",
		[cell.x, cell.y, facing.x, facing.y, character_id]
	)

	if result != OK:
		return [ERR_DATABASE_CANT_WRITE, "DATABASE_ERROR"]

	return [OK, null]


func update_character_map(character_id: int, map_id: int, cell: Vector2i, facing: Vector2i) -> Array:
	var result: Error = await _database.exec(
		"UPDATE characters SET map = ?, cell_x = ?, cell_y = ?, facing_x = ?, facing_y = ? WHERE id = ?",
		[map_id, cell.x, cell.y, facing.x, facing.y, character_id]
	)

	if result != OK:
		return [ERR_DATABASE_CANT_WRITE, "DATABASE_ERROR"]

	return [OK, null]


func update_access(character_id: int) -> Array:
	var result: Error = await _database.exec(
		"UPDATE characters SET access_at = ? WHERE id = ?",
		[_database.now(), character_id]
	)

	if result != OK:
		return [ERR_DATABASE_CANT_WRITE, "DATABASE_ERROR"]

	return [OK, null]


func update_updated(character_id: int) -> Array:
	var result: Error = await _database.exec(
		"UPDATE characters SET updated_at = ? WHERE id = ?",
		[_database.now(), character_id]
	)

	if result != OK:
		return [ERR_DATABASE_CANT_WRITE, "DATABASE_ERROR"]

	return [OK, null]


func _is_identifier_valid(identifier: String) -> bool:
	return RegEx.create_from_string(Constants.IDENTIFIER_REGEX).search(identifier) != null
