extends Repository
class_name AccountRepository


func table_query() -> String:
	return """
		CREATE TABLE IF NOT EXISTS accounts (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			email TEXT NOT NULL UNIQUE,
			password TEXT NOT NULL,
			is_banned INTEGER NOT NULL DEFAULT 0,
			max_characters INTEGER NOT NULL DEFAULT 3,
			access_at INTEGER NOT NULL DEFAULT 0,
			banned_at INTEGER NOT NULL DEFAULT 0,
			created_at INTEGER NOT NULL,
			updated_at INTEGER NOT NULL
		);
	"""


func create(email: String, password_hash: String) -> AccountModel:
	var err: Error = await exec(
		"INSERT INTO accounts (email, password, created_at, updated_at) VALUES (?1, ?2, ?3, ?4);",
		[email, password_hash, now(), now()]
	)
	if err != OK:
		return null

	return await get_by_email(email)


func get_all() -> Array[Model]:
	return await rows("SELECT * FROM accounts;", [], AccountModel)


func get_by_id(id: int) -> AccountModel:
	return await row("SELECT * FROM accounts WHERE id = ?1 LIMIT 1;", [id], AccountModel) as AccountModel


func get_by_email(email: String) -> AccountModel:
	return await row("SELECT * FROM accounts WHERE email = ?1 LIMIT 1;", [email], AccountModel) as AccountModel


func update(id: int, fields: Dictionary) -> AccountModel:
	fields["updated_at"] = now()

	var keys: Array = fields.keys()
	var sets: Array = []

	for i: int in keys.size():
		sets.push_back("%s = ?%d" % [keys[i], i + 1])

	var query: String = "UPDATE accounts SET %s WHERE id = ?%d;" % [", ".join(sets), keys.size() + 1]
	var params: Array = fields.values()

	params.append(id)

	var err: Error = await exec(query, params)
	if err != OK:
		return null

	return await get_by_id(id)


func ban(id: int) -> AccountModel:
	return await update(id, {"is_banned": 1, "banned_at": now()})


func unban(id: int) -> AccountModel:
	return await update(id, {"is_banned": 0, "banned_at": 0})


func touch_access(id: int) -> AccountModel:
	return await update(id, {"access_at": now()})


func set_max_characters(id: int, count: int) -> AccountModel:
	return await update(id, {"max_characters": count})
