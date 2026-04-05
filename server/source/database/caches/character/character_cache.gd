extends Cache
class_name CharacterCache


func load_all() -> void:
	for entry: CharacterModel in await (_repository as CharacterRepository).get_all():
		entries[entry.id] = entry

	print(tr("CACHE_LOADED_CHARACTERS") % entries.size())


func create(account_id: int, identifier: String, sprite: String) -> CharacterModel:
	var model: CharacterModel = await (_repository as CharacterRepository).create(account_id, identifier, sprite)
	if model == null:
		return null

	entries[model.id] = model

	return model


func get_all() -> Array[Model]:
	return entries.values()


func get_by_id(id: int) -> CharacterModel:
	return entries.get(id) as CharacterModel


func get_by_account(account_id: int) -> Array[Model]:
	var result: Array[Model] = []
	for entry: CharacterModel in entries.values():
		if entry.account_id == account_id && entry.deleted_at == 0:
			result.push_back(entry)
	return result


func get_by_identifier(identifier: String) -> CharacterModel:
	for entry: CharacterModel in entries.values():
		if entry.identifier == identifier:
			return entry
	return null


func touch_access(id: int) -> CharacterModel:
	var model: CharacterModel = await (_repository as CharacterRepository).touch_access(id)
	if model == null:
		return null

	entries[model.id] = model

	return model


func move(id: int, map_id: int, position_x: int, position_y: int, direction_x: int, direction_y: int) -> CharacterModel:
	var model: CharacterModel = await (_repository as CharacterRepository).move(id, map_id, position_x, position_y, direction_x, direction_y)
	if model == null:
		return null

	entries[model.id] = model

	return model


func soft_delete(id: int) -> CharacterModel:
	var model: CharacterModel = await (_repository as CharacterRepository).soft_delete(id)
	if model == null:
		return null

	entries[model.id] = model

	return model


func restore(id: int) -> CharacterModel:
	var model: CharacterModel = await (_repository as CharacterRepository).restore(id)
	if model == null:
		return null

	entries[model.id] = model

	return model
