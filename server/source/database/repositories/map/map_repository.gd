extends Repository
class_name MapRepository


func table_query() -> String:
	return """
		CREATE TABLE IF NOT EXISTS maps (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			resource TEXT NOT NULL UNIQUE,
			created_at INTEGER NOT NULL,
			updated_at INTEGER NOT NULL
		);
	"""


func indexes_queries() -> Array[String]:
	return [
		"CREATE INDEX IF NOT EXISTS idx_maps_resource ON maps (resource);",
	]


func create(resource: String) -> MapModel:
	var err: Error = await exec(
		"INSERT INTO maps (resource, created_at, updated_at) VALUES (?1, ?2, ?3);",
		[resource, now(), now()]
	)
	if err != OK:
		return null

	return await get_by_resource(resource)


func get_all() -> Array[Model]:
	return await rows("SELECT * FROM maps;", [], MapModel)


func get_by_id(id: int) -> MapModel:
	return await row("SELECT * FROM maps WHERE id = ?1 LIMIT 1;", [id], MapModel) as MapModel


func get_by_resource(resource: String) -> MapModel:
	return await row("SELECT * FROM maps WHERE resource = ?1 LIMIT 1;", [resource], MapModel) as MapModel


func update(id: int, fields: Dictionary) -> MapModel:
	fields["updated_at"] = now()

	var keys: Array = fields.keys()
	var sets: Array = []

	for i: int in keys.size():
		sets.push_back("%s = ?%d" % [keys[i], i + 1])

	var query: String = "UPDATE maps SET %s WHERE id = ?%d;" % [", ".join(sets), keys.size() + 1]
	var params: Array = fields.values()

	params.append(id)

	var err: Error = await exec(query, params)
	if err != OK:
		return null

	return await get_by_id(id)
