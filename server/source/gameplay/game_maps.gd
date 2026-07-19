extends Node


var _maps: Dictionary[int, Map] = {}


func load_map(map_id: int) -> Map:
	if _maps.has(map_id):
		return _maps[map_id]

	var map_data_path: String = Constants.MAPS_PATH + "map_%d.tres" % str(map_id)
	if not ResourceLoader.exists(map_data_path):
		push_error("Mapa não encontrado: ", map_data_path)
		return null

	var map_data: Resource = load(map_data_path)
	if not map_data:
		push_error("Falha ao carregar mapa: ", map_data_path)
		return null

	var map = Map.new(
		map_data.id,
		map_data.identifier,
		map_data.bgm,
		map_data.bgs,
		map_data.width,
		map_data.height
	)

	var collision_path: String = Constants.MAPS_PATH + "collisions/map_%d.tres" % str(map_id)
	if ResourceLoader.exists(collision_path):
		var collision_resource: MapCollisionData = load(collision_path)
		map.import_collisions(collision_resource)

	_maps[map_id] = map
	return map


func map(map_id: int) -> Map:
	return _maps.get(map_id, null)


func has_map(map_id: int) -> bool:
	return _maps.has(map_id)


func unload_map(map_id: int) -> void:
	if _maps.has(map_id):
		_maps.erase(map_id)


func unload_all() -> void:
	_maps.clear()


func loaded_maps() -> Array[int]:
	return _maps.keys()
