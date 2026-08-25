extends RefCounted
class_name MapModule


var _maps: Dictionary[int, Map] = {}


func map(map_id: int) -> Map:
	return _maps.get(map_id)


func has(map_id: int) -> bool:
	return _maps.has(map_id)


func count() -> int:
	return _maps.size()


func all() -> Array[Map]:
	return _maps.values()


func load_all_from_disk() -> void:
	for map_id: int in _scan_directory_ids():
		load_from_disk(map_id)


func load_from_disk(map_id: int) -> bool:
	if has(map_id):
		return true

	var map_path: String = Constants.MAPS_DATA_DIRECTORY + "%d.tres" % map_id
	if not ResourceLoader.exists(map_path):
		push_error("Mapa %d não encontrado: %s" % [map_id, map_path])
		return false

	var map_data: MapData = load(map_path)
	if not map_data:
		push_error("Falha ao carregar dados do mapa %d" % map_id)
		return false

	var map: Map = Map.new(
		map_data.id,
		map_data.identifier,
		map_data.bgm,
		map_data.bgs,
		map_data.size,
	)

	if not map_data.collisions.is_empty():
		map.import_collisions(map_data.collisions)

	_maps[map_data.id] = map

	print("Mapa %d carregado: %s (%dx%d) com %d colisões" % [
		map_id,
		map.identifier,
		map.size.x,
		map.size.y,
		map.collisions.size()
	])

	return true


func update_collisions(map_id: int, new_collisions: Dictionary[Vector2i, int]) -> void:
	var map: Map = map(map_id)
	if not map:
		push_error("Mapa %d não encontrado" % map_id)
		return

	map.import_collisions(new_collisions)

	var map_path: String = Constants.MAPS_DATA_DIRECTORY + "%d.tres" % map_id
	var map_data: MapData = load(map_path)
	if not map_data:
		push_error("Falha ao carregar MapData do mapa %d" % map_id)
		return

	map_data.collisions = new_collisions.duplicate()

	var err: int = ResourceSaver.save(map_data, map_path)
	if err != OK:
		push_error("Falha ao salvar mapa %d: %s" % [map_id, error_string(err)])
		return


func _scan_directory_ids() -> Array[int]:
	var ids: Array[int] = []
	var dir: DirAccess = DirAccess.open(Constants.MAPS_DATA_DIRECTORY)
	if not dir:
		push_error("Não foi possível abrir: %s" % Constants.MAPS_DATA_DIRECTORY)
		return ids

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var id_str: String = file_name.trim_suffix(".tres")
			if id_str.is_valid_int():
				ids.append(id_str.to_int())
		file_name = dir.get_next()
	dir.list_dir_end()

	return ids
