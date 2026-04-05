extends Cache
class_name MapCache


func load_all() -> void:
	for entry: MapModel in await (_repository as MapRepository).get_all():
		entries[entry.id] = entry

	print(tr("CACHE_LOADED_MAPS") % entries.size())


func create(resource: String) -> MapModel:
	var model: MapModel = await (_repository as MapRepository).create(resource)
	if model == null:
		return null

	entries[model.id] = model

	return model


func get_all() -> Array[Model]:
	return entries.values()


func get_by_id(id: int) -> MapModel:
	return entries.get(id) as MapModel


func get_by_resource(resource: String) -> MapModel:
	for entry: MapModel in entries.values():
		if entry.resource == resource:
			return entry
	return null
