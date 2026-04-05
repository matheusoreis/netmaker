extends Cache
class_name AccountCache


func load_all() -> void:
	for entry: AccountModel in await (_repository as AccountRepository).get_all():
		entries[entry.id] = entry

	print(tr("CACHE_LOADED_ACCOUNTS") % entries.size())


func create(email: String, password_hash: String) -> AccountModel:
	var model: AccountModel = await (_repository as AccountRepository).create(email, password_hash)
	if model == null:
		return null

	entries[model.id] = model

	return model


func get_all() -> Array[Model]:
	return entries.values()


func get_by_id(id: int) -> AccountModel:
	return entries.get(id) as AccountModel


func get_by_email(email: String) -> AccountModel:
	for entry: AccountModel in entries.values():
		if entry.email == email:
			return entry
	return null


func ban(id: int) -> AccountModel:
	var model: AccountModel = await (_repository as AccountRepository).ban(id)
	if model == null:
		return null

	entries[model.id] = model

	return model


func unban(id: int) -> AccountModel:
	var model: AccountModel = await (_repository as AccountRepository).unban(id)
	if model == null:
		return null

	entries[model.id] = model

	return model


func touch_access(id: int) -> AccountModel:
	var model: AccountModel = await (_repository as AccountRepository).touch_access(id)
	if model == null:
		return null

	entries[model.id] = model

	return model


func set_max_characters(id: int, count: int) -> AccountModel:
	var model: AccountModel = await (_repository as AccountRepository).set_max_characters(id, count)
	if model == null:
		return null

	entries[model.id] = model

	return model
