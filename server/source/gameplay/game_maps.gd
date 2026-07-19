extends Node


var _maps: Dictionary[int, Map] = {}


func load_all_maps() -> void:
	var dir = DirAccess.open(Constants.MAPS_PATH)
	if not dir:
		push_error("[MAP] Não foi possível abrir o diretório: ", Constants.MAPS_PATH)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if file_name.ends_with(".tres") and file_name.begins_with("map_"):
			var map_id = int(file_name.substr(4, 3))
			load_map(map_id)
		file_name = dir.get_next()

	print("[MAP] %d Mapa(s) carregados com sucesso." % [_maps.size()])

	dir.list_dir_end()


func load_map(map_id: int) -> Map:
	if _maps.has(map_id):
		return _maps[map_id]

	var map_data_path: String = Constants.MAPS_PATH + "map_%d.tres" % map_id
	if not ResourceLoader.exists(map_data_path):
		push_error("[MAP] Mapa não encontrado: ", map_data_path)
		return null

	var map_data: MapData = load(map_data_path)
	if not map_data:
		push_error("[MAP] Falha ao carregar mapa: ", map_data_path)
		return null

	var map = Map.new(
		map_data.id,
		map_data.identifier,
		map_data.bgm,
		map_data.bgs,
		map_data.width,
		map_data.height
	)

	var collision_path: String = Constants.MAPS_PATH + "collisions/map_%d.tres" % map_id
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


func map_exists(map_id: int) -> bool:
	var path: String = Constants.MAPS_PATH + "map_%d.tres" % map_id
	return ResourceLoader.exists(path)


func get_all_map_ids() -> Array[int]:
	var ids: Array[int] = []
	var dir = DirAccess.open(Constants.MAPS_PATH)
	if not dir:
		return ids

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if file_name.ends_with(".tres") and file_name.begins_with("map_"):
			var map_id = int(file_name.substr(4, 3))
			ids.append(map_id)

		file_name = dir.get_next()

	dir.list_dir_end()
	return ids
