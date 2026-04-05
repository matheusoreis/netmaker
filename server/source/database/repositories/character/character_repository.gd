extends Repository
class_name CharacterRepository


func table_query() -> String:
	return """
		CREATE TABLE IF NOT EXISTS characters (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			account_id INTEGER NOT NULL,
			map_id INTEGER NOT NULL DEFAULT 1,
			identifier TEXT NOT NULL UNIQUE,
			sprite TEXT NOT NULL,
			position_x INTEGER NOT NULL DEFAULT 0,
			position_y INTEGER NOT NULL DEFAULT 0,
			facing_x INTEGER NOT NULL DEFAULT 0,
			facing_y INTEGER NOT NULL DEFAULT 0,
			access_at INTEGER NOT NULL DEFAULT 0,
			deleted_at INTEGER NOT NULL DEFAULT 0,
			created_at INTEGER NOT NULL,
			updated_at INTEGER NOT NULL,
			FOREIGN KEY (account_id) REFERENCES accounts(id)
		);
	"""


func indexes_queries() -> Array[String]:
	return [
		"CREATE INDEX IF NOT EXISTS idx_characters_account_id ON characters (account_id);",
		"CREATE INDEX IF NOT EXISTS idx_characters_identifier ON characters (identifier);",
	]


func create(account_id: int, identifier: String, sprite: String) -> CharacterModel:
	var err: Error = await exec(
		"INSERT INTO characters (account_id, map_id, identifier, sprite, created_at, updated_at) VALUES (?1, ?2, ?3, ?4, ?5, ?6);",
		[account_id, 1, identifier, sprite, now(), now()]
	)
	if err != OK:
		return null

	return await get_by_identifier(identifier)


func get_all() -> Array[Model]:
	return await rows("SELECT * FROM characters;", [], CharacterModel)


func get_by_id(id: int) -> CharacterModel:
	return await row("SELECT * FROM characters WHERE id = ?1 LIMIT 1;", [id], CharacterModel) as CharacterModel


func get_by_account(account_id: int) -> Array[Model]:
	return await rows("SELECT * FROM characters WHERE account_id = ?1 AND deleted_at = 0;", [account_id], CharacterModel)


func get_by_identifier(identifier: String) -> CharacterModel:
	return await row("SELECT * FROM characters WHERE identifier = ?1 LIMIT 1;", [identifier], CharacterModel) as CharacterModel


func update(id: int, fields: Dictionary) -> CharacterModel:
	fields["updated_at"] = now()

	var keys: Array = fields.keys()
	var sets: Array = []

	for i: int in keys.size():
		sets.push_back("%s = ?%d" % [keys[i], i + 1])

	var query: String = "UPDATE characters SET %s WHERE id = ?%d;" % [", ".join(sets), keys.size() + 1]
	var params: Array = fields.values()

	params.append(id)

	var err: Error = await exec(query, params)
	if err != OK:
		return null

	return await get_by_id(id)


func touch_access(id: int) -> CharacterModel:
	return await update(id, {"access_at": now()})


func move(id: int, map_id: int, position_x: int, position_y: int, facing_x: int, facing_y: int) -> CharacterModel:
	return await update(id, {
		"map_id": map_id,
		"position_x": position_x,
		"position_y": position_y,
		"facing_x": facing_x,
		"facing_y": facing_y,
	})


func soft_delete(id: int) -> CharacterModel:
	return await update(id, {"deleted_at": now()})


func restore(id: int) -> CharacterModel:
	return await update(id, {"deleted_at": 0})
