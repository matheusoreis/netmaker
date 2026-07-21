extends Node


const _MAP_FILE_PREFIX: String = "map_"
const _MAP_FILE_SUFFIX: String = ".tres"

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

	var map_data_path: String = _map_data_path(map_id)
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
		map_data.height,
		map_data.actor_collision
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


func count() -> int:
	return _maps.size()


func all_ids() -> Array[int]:
	var ids: Array[int] = []
	ids.assign(_maps.keys())
	return ids


func unload_map(map_id: int) -> void:
	_maps.erase(map_id)


func unload_all() -> void:
	_maps.clear()


func clear_actors(map_id: int) -> void:
	var target: Map = _get_loaded(map_id)
	if not target:
		return

	target.clear_actors()


func clear_collisions(map_id: int) -> void:
	var target: Map = _get_loaded(map_id)
	if not target:
		return

	target.clear_collisions()


func reload_collisions(map_id: int) -> void:
	var target: Map = _get_loaded(map_id)
	if not target:
		return

	var collision_path: String = _collision_path(map_id)
	if not ResourceLoader.exists(collision_path):
		target.clear_collisions()
		return

	var collision_resource: MapCollisionData = load(collision_path)
	target.import_collisions(collision_resource)


func exists_on_disk(map_id: int) -> bool:
	return ResourceLoader.exists(_map_data_path(map_id))


func place_actor(map_id: int, position: Vector2i, peer_id: int) -> void:
	var target: Map = _get_loaded(map_id)
	if not target:
		return

	target.place_actor(position, peer_id)


func remove_actor(map_id: int, position: Vector2i, peer_id: int) -> void:
	var target: Map = _get_loaded(map_id)
	if not target:
		return

	target.remove_actor(position, peer_id)


func _map_data_path(map_id: int) -> String:
	return Constants.MAPS_PATH + "%s%d%s" % [_MAP_FILE_PREFIX, map_id, _MAP_FILE_SUFFIX]


func _collision_path(map_id: int) -> String:
	return Constants.MAPS_PATH + "collisions/%s%d%s" % [_MAP_FILE_PREFIX, map_id, _MAP_FILE_SUFFIX]


## Busca um mapa carregado e avisa no log quando a operação é ignorada
## por o mapa ainda não estar em memória (evita falhas silenciosas).
func _get_loaded(map_id: int) -> Map:
	var target: Map = _maps.get(map_id)
	if not target:
		push_warning("[MAP] Operação ignorada, mapa %d não está carregado." % map_id)
	return target


func _scan_directory_ids() -> Array[int]:
	var ids: Array[int] = []

	var directory := DirAccess.open(Constants.MAPS_PATH)
	if not directory:
		push_error("[MAP] Não foi possível abrir o diretório: ", Constants.MAPS_PATH)
		return ids

	directory.list_dir_begin()
	var file_name := directory.get_next()

	while file_name != "":
		if (
			not directory.current_is_dir()
			and file_name.begins_with(_MAP_FILE_PREFIX)
			and file_name.ends_with(_MAP_FILE_SUFFIX)
		):
			var id_str: String = file_name.trim_prefix(_MAP_FILE_PREFIX).trim_suffix(_MAP_FILE_SUFFIX)
			if id_str.is_valid_int():
				ids.append(id_str.to_int())
			else:
				push_warning("[MAP] Arquivo de mapa com nome inesperado ignorado: %s" % file_name)

		file_name = directory.get_next()

	directory.list_dir_end()
	return ids
