extends Node


var _maps: Dictionary[int, Map] = {}


func load_all() -> void:
	for map_id: int in _scan_directory_ids():
		load_map(map_id)

	print("[MAP] %d Mapa(s) carregados com sucesso." % [_maps.size()])


func load_map(map_id: int) -> void:
	if has(map_id):
		return

	if not exists_on_disk(map_id):
		push_error("[MAP] Mapa não encontrado: ", map_id)
		return

	var map_data_path: String = Constants.MAPS_PATH + "map_%d.tres" % map_id
	var map_data: MapData = load(map_data_path)
	if not map_data:
		push_error("[MAP] Falha ao carregar mapa: ", map_data_path)
		return

	var new_map := Map.new(
		map_data.id,
		map_data.identifier,
		map_data.bgm,
		map_data.bgs,
		map_data.width,
		map_data.height
	)

	var collision_path: String = _collision_path(map_id)
	if ResourceLoader.exists(collision_path):
		var collision_resource: MapCollisionData = load(collision_path)
		new_map.import_collisions(collision_resource)

	_maps[map_id] = new_map


func map(map_id: int) -> Map:
	return _maps.get(map_id, null)


func has(map_id: int) -> bool:
	return _maps.has(map_id)


func unload_map(map_id: int) -> void:
	_maps.erase(map_id)


func unload_all() -> void:
	_maps.clear()


func clear_blockers(map_id: int) -> void:
	var target: Map = _maps.get(map_id)
	if not target:
		return

	target.clear_blockers()


func clear_collisions(map_id: int) -> void:
	var target: Map = _maps.get(map_id)
	if not target:
		return

	target.clear_collisions()


func reload_collisions(map_id: int) -> void:
	var target: Map = _maps.get(map_id)
	if not target:
		return

	var collision_path: String = _collision_path(map_id)
	if not ResourceLoader.exists(collision_path):
		target.clear_collisions()
		return

	var collision_resource: MapCollisionData = load(collision_path)
	target.import_collisions(collision_resource)


func _collision_path(map_id: int) -> String:
	return Constants.MAPS_PATH + "collisions/map_%d.tres" % map_id


func exists_on_disk(map_id: int) -> bool:
	var path: String = Constants.MAPS_PATH + "map_%d.tres" % map_id
	return ResourceLoader.exists(path)


func place_occupant(map_id: int, position: Vector2i, entity_id: int) -> void:
	var target: Map = _maps.get(map_id)
	if not target:
		return

	target.occupy(position, entity_id)


func remove_occupant(map_id: int, position: Vector2i, entity_id: int) -> void:
	var target: Map = _maps.get(map_id)
	if not target:
		return

	target.vacate(position, entity_id)


func _scan_directory_ids() -> Array[int]:
	var ids: Array[int] = []

	var directory := DirAccess.open(Constants.MAPS_PATH)
	if not directory:
		push_error("[MAP] Não foi possível abrir o diretório: ", Constants.MAPS_PATH)
		return ids

	directory.list_dir_begin()
	var file_name := directory.get_next()

	while file_name != "":
		if file_name.ends_with(".tres") and file_name.begins_with("map_"):
			ids.append(int(file_name.substr(4, 3)))

		file_name = directory.get_next()

	directory.list_dir_end()
	return ids
