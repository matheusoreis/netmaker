extends RefCounted
class_name Repository


var db: AsletConn


func _init(database: AsletConn) -> void:
	db = database

	var name: StringName = get_script().get_global_name()
	print(tr("SQLITE_REPOSITORY_STARTING") % name)

	if _create_table() != OK:
		push_error(tr("SQLITE_REPOSITORY_TABLE_FAILED") % name)
		return

	if _create_indexes() != OK:
		push_error(tr("SQLITE_REPOSITORY_INDEX_FAILED") % name)
		return

	print(tr("SQLITE_REPOSITORY_STARTED") % name)


func now() -> int:
	return int(Time.get_unix_time_from_system())


func table_query() -> String:
	return ""


func indexes_queries() -> Array[String]:
	return []


func rows(query: String, args: Array = [], ty: GDScript = null) -> Array[Model]:
	var result: Array = await db.fetch(query, args).done as Array
	if result[0] != OK:
		return []

	var cols: PackedStringArray = result[2] as PackedStringArray
	var values: Array[Model] = []

	for row: Array in result[1]:
		if ty == null:
			break
		var m: Model = ty.new() as Model
		m.from_row(row, cols)
		values.push_back(m)
	return values


func row(query: String, args: Array = [], ty: GDScript = null) -> Model:
	var result: Array = await db.fetch(query, args).done as Array
	if result[0] != OK || (result[1] as Array).size() == 0:
		return null

	if ty == null:
		return null

	var m: Model = ty.new() as Model
	m.from_row(result[1][0] as Array, result[2] as PackedStringArray)
	return m


func scalar(query: String, args: Array = []) -> Variant:
	var result: Array = await db.fetch(query, args).done as Array
	if result[0] != OK || (result[1] as Array).size() == 0:
		return null
	return (result[1] as Array)[0][0]


func scalar_or(query: String, args: Array = [], default: Variant = null) -> Variant:
	var value: Variant = await scalar(query, args)
	return default if value == null else value


func exec(query: String, params: Array = []) -> Error:
	var result: Array = await db.exec(query, params).done as Array
	if result[0] != OK:
		push_error(tr("SQLITE_REPOSITORY_TABLE_ERROR") % result[2])
		return result[0] as Error
	return OK


func _create_table() -> Error:
	var query: String = table_query()
	if query.is_empty():
		return OK

	var result: Array = db.exec(query, []).wait() as Array
	return OK if result[0] == OK else FAILED


func _create_indexes() -> Error:
	for query: String in indexes_queries():
		var result: Array = db.exec(query, []).wait() as Array
		if result[0] != OK:
			return FAILED
	return OK
